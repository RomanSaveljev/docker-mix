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

sameCommand = (a, b) -> a.constructor == b.constructor

class Dockerfile
  constructor: ->
    @commands = []
  count: -> return @commands.length
  add: (command) ->
    if command.overrides() and @commands.filter((c) -> sameCommand(c, command)).length > 0
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
      if sameCommand(c, command)
        for dep in @commands
          dep.after = command if dep.after == c
        command.after = c.after
        @commands[i] = command
        return command
    @add(command)
  build: (dockerfile = [], context = new FinalizingContext(new Pack()))->
    commands = clone(@commands)
    # Make indepdendent commands dependent
    makeDependent = (c) ->
      for cmd in commands
        if sameCommand(cmd, c) and cmd.after?
          c.after = cmd.after
          break
    commands.filter((c) -> !c.after?).forEach(makeDependent)
    # Create reverse links for simple walking
    root = {next: [], root: true}
    commands.filter((c) -> !c.after?).forEach((c) -> c.after = root)
    commands.forEach((c) -> c.next = [])
    commands.forEach((c) -> c.after.next.push(c))
    walkLayer = (layer, dockerfile, context) ->
      return unless layer.length > 0
      sorted = groupByAppearanceOrder(layer)
      aggregate = (list, type, ctor) ->
        byType = list.filter((c) -> c.constructor == type)
        if byType.length > 0
          aggregated = new ctor(byType[0])
          aggregated.next = byType[0].next
          aggregateMore = (more) ->
            newAggregated = new ctor(aggregated, more)
            newAggregated.next = aggregated.next.concat(more.next)
            aggregated = newAggregated
          byType[1..].forEach(aggregateMore)
          # sorted is ordered by type
          start = list.indexOf(byType[0])
          list[start...(start + byType.length)] = aggregated
          #list.splice(list.indexOf(byType[0]), byType.length, aggregated)
      aggregate(sorted, Env, MultiEnv)
      aggregate(sorted, Expose, MultiExpose)
      aggregate(sorted, Label, MultiLabel)
      aggregate(sorted, Run, MultiRun)
      aggregate(sorted, Volume, MultiVolume)
      aggregate(sorted, ContextCopy, MultiContextCopy)
      for command in sorted
        command.applyTo(context, dockerfile)
        walkLayer(command.next, dockerfile, context)
    walkLayer(root.next, dockerfile, context)
    context.entry({name: '/Dockerfile'}, dockerfile.join("\n"))
    context.finalize()
    return context

module.exports = Dockerfile
