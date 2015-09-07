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
    newList[0] = new ctor(byType[0])
    newList[0].next = byType[0].next
    aggregateMore = (more) ->
      if more.next.length == 0
        aggregated = new ctor(newList[0], more)
        aggregated.next = newList[0].next
        newList[0] = aggregated
      else
        aggregated = new ctor(more)
        aggregated.next = more.next
        newList.push(aggregated)
    byType[1..].forEach(aggregateMore)
    # sorted is ordered by type
    start = list.indexOf(byType[0])
    list[start...(start + byType.length)] = newList
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
        if sameCommand(cmd, c) and cmd.after != c and cmd.after?
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
      #noDependants = layer.filter((c) -> c.next.length == 0)
      sorted = groupByAppearanceOrder(layer)
      # Combine commands without dependants
      aggregate(sorted, map.single, map.multi) for map in aggregateMap
      # We know that nothing depends on what we just combined
      for command in sorted
        #dockerfile.push('# Current layer command')
        command.applyTo(context, dockerfile)
        #dockerfile.push('# Walking dependants')
        walkLayer(command.next, dockerfile, context)
        #dockerfile.push('# Dependants walked')
    walkLayer([from], dockerfile, context)
    context.entry({name: '/Dockerfile'}, dockerfile.join("\n"))
    context.finalize()
    return context

module.exports = Dockerfile
