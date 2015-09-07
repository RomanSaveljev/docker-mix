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
  count: -> return @commands.length
  add: (command) ->
    if command.overrides() and @commands.filter((c) -> functions.sameCommand(c, command)).length > 0
      throw new Error("Command already added. Call override() to override it")
    @commands.push(command)
    command.doBefore = (command) ->
      command.doAfter(@)
      return @
    command.doAfter = (after) =>
      throw new Error("Add/Override this command to Dockerfile first") if @commands.indexOf(after) == -1
      command.after = after
      return command
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
    # Make independent commands dependent
    makeDependent = (c) ->
      for cmd in commands
        if functions.sameCommand(cmd, c) and cmd.after != c and cmd.after?
          c.after = cmd.after
          break
    #commands.filter((c) -> !c.after?).forEach(makeDependent)
    # Create reverse links for simple walking
    commands.filter((c) -> !c.after?).forEach((c) -> c.after = from)
    commands.forEach((c) -> c.after.next.push(c))
    flat = []
    # Walks a single layer of command dependants
    walkLayer = (dependency, layer) ->
      return unless layer.length > 0
      copy = layer[0..]
      # All commands in the same layer are equal, but the same as dependency
      # command need to be moved to the top, so it can be aggregated in the flat
      # array
      for c, i in copy
        if functions.combinesTo(c) == functions.combinesTo(dependency)
          circular = copy[0..i]
          circular.unshift(circular.pop())
          copy[0..i] = circular
          break
      sorted = groupByAppearanceOrder(copy)
      # Combine commands without dependants
      functions.aggregate(sorted)
      # We know that nothing depends on what we just combined
      for command in sorted
        flat.push(command)
        walkLayer(command, command.next)
    walkLayer({}, [from])
    command.applyTo(context, dockerfile) for command in flat
    context.entry({name: '/Dockerfile'}, dockerfile.join("\n"))
    context.finalize()
    return context

module.exports = Dockerfile
