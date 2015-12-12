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

class Dockerfile
  constructor: ->
    @commands = []
  count: -> @commands.length
  add: (command) ->
    if command.overrides() and @commands.filter((c) -> functions.sameCommand(c, command)).length > 0
      throw new Error("Command already added. Call override() to override it")
    @commands.push(command)
    command.doBefore = (cmd) ->
      cmd.doAfter(@)
      return @
    dockerfile = @
    command.doAfter = (after) ->
      if dockerfile.commands.indexOf(after) == -1
        throw new Error("Add/Override this command to Dockerfile first")
      @after = after
      return @
    command.next = (next) ->
      dockerfile.add(next).doAfter(@)
      # Updates the first element in the tight group
      next.doAfter = (after) => @doAfter(after)
      return next
    return command
  override: (command) ->
    unless command.overrides()
      throw new Error("This command does not override")
    for c, i in @commands
      if functions.sameCommand(c, command)
        for dep in @commands
          dep.after = command if dep.after == c
        command.after = c.after
        @commands[i] = command
        return command
    @add(command)
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
    walkLayer({}, [from])
    # Erase all information about links
    delete c.next for c in flat
    # Aggregate again on a flat structure
    functions.aggregate(flat)
    command.applyTo(context, dockerfile) for command in flat
    context.entry({name: '/Dockerfile'}, dockerfile.join("\n"))
    context.finalize()
    return context

module.exports = Dockerfile
