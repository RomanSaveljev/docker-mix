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

class Dockerfile
  constructor: ->
    @commands = []
  count: -> return @commands.length
  add: (command) ->
    if command.overrides() and @commands.filter((c) -> c.keyword() == command.keyword()).length > 0
      throw new Error("#{command.keyword()} already added. Call override() to override it")
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
      if c.keyword() == command.keyword()
        for dep in @commands
          dep.after = command if dep.after == c
        command.after = c.after
        @commands[i] = command
        return command
    @add(command)
  toString: ->
    output = ""
    commands = clone(@commands)
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

module.exports = Dockerfile
