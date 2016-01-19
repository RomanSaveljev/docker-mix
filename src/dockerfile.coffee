extend = require('extend')
clone = require('clone')
Env = require('./commands/env')
MultiEnv = require('./commands/multi-env')
Run = require('./commands/run')
MultiRun = require('./commands/multi-run')
Expose = require('./commands/expose')
MultiExpose = require('./commands/multi-expose')
Volume = require('./commands/volume')
MultiVolume = require('./commands/multi-volume')
Label = require('./commands/label')
MultiLabel = require('./commands/multi-label')
ContextCopy = require('./commands/context-copy')
MultiContextCopy = require('./commands/multi-context-copy')
groupByAppearanceOrder = require('./group-by-appearance-order')
FinalizingContext = require('./finalizing-context')
Pack = require('./pack')
From = require('./commands/from')
functions = require('./dockerfile-functions')
NullAggregator = require './commands/null-aggregator'

updateExistingLabelOrCreateNew = (label, command, labels) ->
  matchAndUpdate = (c) ->
    if c.label is label
      c.command = command
      return true
    return false
  unless labels.some(matchAndUpdate)
    labels.push(label: label, command: command)

augmentCommand = (command, dockerfile) ->
  command.doBefore = (cmd) ->
    cmd.doAfter(@)
    return @
  command.doAfter = (after) ->
    if dockerfile.commands.indexOf(after) == -1
      throw new Error("Add/Override this command to Dockerfile first")
    @after = after
    return @
  command.next = (next, label) ->
    dockerfile.add(next, label).doAfter(@)
    # Updates the first element in the tight group
    next.doAfter = (after) => @doAfter(after)
    return next
  return command

class DummyStatement
  @aggregator: () -> new NullAggregator()

class Dockerfile
  constructor: ->
    @commands = []
    @labels = []
  count: -> @commands.length
  add: (command, label) ->
    if command.overrides() and @commands.filter((c) -> functions.sameCommand(c, command)).length > 0
      throw new Error("Command already added. Call override() to override it")
    updateExistingLabelOrCreateNew(label, command, @labels) if label?
    @commands.push(augmentCommand(command, @))
    return command
  override: (command, label) ->
    unless command.overrides()
      throw new Error("This command does not override")
    idx = -1
    for c, i in @commands
      if functions.sameCommand(c, command)
        for dep in @commands
          dep.after = command if dep.after == c
        command.after = c.after
        @commands[i] = command
        idx = i
        break
    if idx is -1
      idx = @commands.length
      @commands.push(command)
    augmentCommand(@commands[idx], @)
    updateExistingLabelOrCreateNew(label, @commands[idx], @labels) if label?
    return @commands[idx]
  build: (dockerfile = [], context = new FinalizingContext(new Pack()))->
    commands = clone(@commands)
    from = commands.filter((c) -> c.constructor == From)[0]
    throw new Error('Missing FROM command') unless from?
    commands.forEach((c) -> c.next = [])
    commands.splice(commands.indexOf(from), 1)
    # Those without 'after' property must be pushed to the end of the list, i.e.
    # relationships defined by user will have higher priority
    noDependencies = commands.filter((c) -> !c.after?)
    commands = commands.filter((c) -> c.after)
    commands.push(noDependencies...)
    # FROM must always be the first
    delete from.after
    commands.filter((c) -> !c.after?).forEach((c) -> c.after = from)
    # Create reverse links for simple walking
    commands.forEach((c) -> c.after.next.push(c))
    flat = []
    # Walks a single layer of command dependants
    walkLayer = (dependency, layer) ->
      return unless layer.length > 0
      copy = layer[0..]
      functions.bumpDependency(copy, dependency)
      sorted = groupByAppearanceOrder(copy)
      for command in sorted
        flat.push(command)
        walkLayer(command, command.next)
    # Walk and aggregate every layer
    walkLayer(new DummyStatement(), [from])
    # Erase all information about links
    delete c.next for c in flat
    # Aggregate again on a flat structure
    functions.aggregate(flat)
    command.applyTo(context, dockerfile) for command in flat
    context.entry({name: '/Dockerfile'}, dockerfile.join("\n"))
    context.finalize()
    return context
  findByLabel: (label) ->
    for e in @labels
      return e.command if e.label is label
    return undefined

module.exports = Dockerfile
