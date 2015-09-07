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

sameCommand = (a, b) -> a.constructor == b.constructor

singleMulti = (single, multi) -> {single: single, multi: multi}

aggregateMap = [
  singleMulti(Env, MultiEnv),
  singleMulti(Expose, MultiExpose),
  singleMulti(Label, MultiLabel),
  singleMulti(Run, MultiRun),
  singleMulti(Volume, MultiVolume),
  singleMulti(ContextCopy, MultiContextCopy)
]

# Updates the list in-place
aggregate = (list, type, ctor) ->
  byType = list.filter((c) -> c.constructor == type)
  newList = []
  if byType.length > 0
    aggregated = new ctor(byType[0])
    aggregated.next = byType[0].next
    newList.push(aggregated)
    aggregateMore = (more) ->
      newAggregated = new ctor(aggregated, more)
      newAggregated.next = aggregated.next
      aggregated = newAggregated
    byType[1..].forEach(aggregateMore)
    # sorted is ordered by type
    start = list.indexOf(byType[0])
    list[start...(start + byType.length)] = aggregated
  return list

aggregateOne = (single, type, ctor) ->
  if single.constructor == type
    aggregated = new ctor(single)
    aggregated.next = single.next
    return aggregated
  else
    return single

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
    from = commands.filter((c) -> c.constructor == From)[0]
    throw new Error('Missing FROM command') unless from?
    commands.forEach((c) -> c.next = [])
    commands.splice(commands.indexOf(from), 1)
    # Make independent commands dependent
    makeDependent = (c) ->
      for cmd in commands
        if sameCommand(cmd, c) and cmd.after?
          c.after = cmd.after
          break
    commands.filter((c) -> !c.after?).forEach(makeDependent)
    # Create reverse links for simple walking
    commands.filter((c) -> !c.after?).forEach((c) -> c.after = from)
    commands.forEach((c) -> c.after.next.push(c))
    # Walks a single layer of command dependants
    walkLayer = (layer, dockerfile, context) ->
      return unless layer.length > 0
      # We only combine those without dependants
      noDependants = layer.filter((c) -> c.next.length == 0)
      sorted = groupByAppearanceOrder(noDependants)
      # Combine commands without dependants
      aggregate(sorted, map.single, map.multi) for map in aggregateMap
      # We know that nothing depends on what we just combined
      command.applyTo(context, dockerfile) for command in sorted
      # After combined multi-commands we create multi-commands for those
      # with dependants
      dependants = layer.filter((c) -> c.next.length > 0)
      for d, i in dependants
        dependants[i] = aggregateOne(dependants[i], map.single, map.multi) for map in aggregateMap
      # Walk dependants depth-first
      for command in dependants
        command.applyTo(context, dockerfile)
        walkLayer(command.next, dockerfile, context)
    walkLayer([from], dockerfile, context)
    context.entry({name: '/Dockerfile'}, dockerfile.join("\n"))
    context.finalize()
    return context

module.exports = Dockerfile
