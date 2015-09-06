extend = require('extend')
clone = require('clone')
MultiEnv = require('./commands/multi-env')
MultiRun = require('./commands/multi-run')
MultiExpose = require('./commands/multi-expose')
MultiVolume = require('./commands/multi-volume')
MultiLabel = require('./commands/multi-label')

PRIORITIES = [
  'FROM'
  'MAINTAINER'
  'LABEL'
  'ENV'
  'EXPOSE'
  'ENTRYPOINT'
  'VOLUME'
  'RUN'
  'ADD'
  'COPY'
  'CMD'
  'USER'
  'WORKDIR'
]

comparePriorities = (a, b) ->
  return PRIORITIES.indexOf(a.keyword()) - PRIORITIES.indexOf(b.keyword())

aggregateCommands = (commands, keyword, ctor) ->
  all = (prev, curr, i) ->
    prev.push(i) if typeof curr != 'number' and curr.keyword() == keyword
    return prev
  indices = commands.reduce(all, [])
  console.dir(indices)
  if indices.length > 1
    commands[indices[0]] = new ctor(commands[indices[0]])
    processor = (i) ->
      commands[indices[0]] = new ctor(commands[indices[0]], commands[i])
      commands[i] = indices[0]
    indices[1..].forEach(processor)
  console.dir('commands = ' + JSON.stringify(commands))

class Dockerfile
  constructor: ->
    @commands = []
  add: (command) ->
    if command.overrides() and @commands.filter((c) -> c.keyword() == command.keyword()).length > 0
      throw new Error("#{command.keyword()} already added. Call override() to override it")
    @commands.push(command)
    command.doBefore = (command) ->
      command.doAfter(@)
    command.doAfter = (after) =>
      index = @commands.indexOf(after)
      throw new Error("Add/Override this command to Dockerfile first") if index == -1
      command.after = index
    command.after = -1
    return command
  override: (command) ->
    unless command.overrides()
      throw new Error("This command does not override")
    for i in [0..(@commands.length - 1)]
      if @commands[i].keyword() == command.keyword()
        command.after = @commands[i].after
        @commands[i] = command
        break
  toString: ->
    output = ""
    commands = clone(@commands)
    # At first, replace indices with references
    commands.forEach((c) -> if c.after == -1 then c.after = undefined else c.after = commands[c.after])
    # Make indepdendent commands dependent
    makeDependent = (c) ->
      for cmd in commands
        if cmd.keyword() == c.keyword() and cmd.after?
          c.after = cmd.after
          break
    commands.filter((c) -> !c.after?).forEach(makeDependent)
    # Create reverse links for simple walking
    root = {next: [], root: true}
    commands.filter((c) -> !c.after?).forEach((c) -> c.after = root)
    commands.forEach((c) -> c.next = [])
    commands.forEach((c) -> c.after.next.push(c))
    walkLayer = (layer) ->
      sorted = layer.sort(comparePriorities)
      aggregate = (list, keyword, ctor) ->
        byKeyword = list.filter((c) -> c.keyword() == keyword)
        if byKeyword.length > 1
          aggregated = new ctor(byKeyword[0])
          aggregated.next = byKeyword[0].next
          aggregateMore = (more) ->
            newAggregated = new ctor(aggregated, more)
            newAggregated.next = aggregated.next.concat(more.next)
            aggregated = newAggregated
          byKeyword[1..].forEach(aggregateMore)
          # sorted is ordered by keyword
          list.splice(list.indexOf(byKeyword[0]), byKeyword.length, aggregated)
      aggregate(sorted, 'ENV', MultiEnv)
      aggregate(sorted, 'EXPOSE', MultiExpose)
      aggregate(sorted, 'LABEL', MultiLabel)
      aggregate(sorted, 'RUN', MultiRun)
      aggregate(sorted, 'VOLUME', MultiVolume)
      for command in sorted
        output += command.toString() + "\n"
        walkLayer(command.next)
    walkLayer(root.next)
    return output
    # Optimize by making independent commands dependent
    for i in [0..(@commands.length - 1)]
      if @commands[i].after == -1
        for j in [i..(@commands.length - 1)]
          if @commands[j].keyword() == @commands[i].keyword() and @commands[j].after != -1
            @commands[i].after = @commands[j].after
            break
    # Walk the array and add dependencies depth first
    iterate = (index) =>
      sorted = @commands.filter((c) -> c.after == index).sort(comparePriorities)
      aggregateCommands(sorted, 'ENV', MultiEnv)
      aggregateCommands(sorted, 'EXPOSE', MultiExpose)
      aggregateCommands(sorted, 'LABEL', MultiLabel)
      aggregateCommands(sorted, 'RUN', MultiRun)
      aggregateCommands(sorted, 'VOLUME', MultiVolume)
      for i in [0..(sorted.length - 1)]
        cmd = sorted[i]
        cmd = sorted[cmd] while typeof cmd == 'number'
        output += cmd.toString() + "\n"
        nextIndex = @commands.indexOf(cmd)
        #iterate(nextIndex)
    for i in [-1..(@commands.length - 1)]
      iterate(i)
    return output

###
    for i in [-1..(@commands.length - 1)]
      filtered = @commands.filter((c) -> c.after == i)
      sorted = filtered.sort(comparePriorities)
      aggregateCommands(sorted, 'ENV', MultiEnv)
      aggregateCommands(sorted, 'EXPOSE', MultiExpose)
      aggregateCommands(sorted, 'LABEL', MultiLabel)
      aggregateCommands(sorted, 'RUN', MultiRun)
      aggregateCommands(sorted, 'VOLUME', MultiVolume)
      sorted.forEach((c) -> output += c.toString() + "\n")
    return output
###

module.exports = Dockerfile
