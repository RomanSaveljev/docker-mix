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

module.exports.sameType = (a, type) -> a.constructor == type

module.exports.sameCommand = (a, b) -> module.exports.sameType(a, b.constructor)

module.exports.aggregateRest = (list, index) ->
  next = index + 1
  # Index should point at the beginning of a suitable region
  aggregator = list[index].constructor.aggregator()
  # Every combinable command becomes a multi-command (with a potential to collect
  # more than one command)
  list[index] = aggregator.aggregate(list[index])
  # Add every following command until it does not combine
  while list.length > next
    return next unless aggregator.equals(list[next].constructor.aggregator())
    list[index] = aggregator.aggregate(list[index], list[next])
    list[(next)..(next)] = []
  return next

# Updates the list in-place, handles continuous regions
module.exports.aggregateRegion = (list) ->
  index = 0
  while (index < list.length)
    index = module.exports.aggregateRest(list, index)
  return list

module.exports.aggregate = (list) ->
  oldLength = list.length
  loop
    module.exports.aggregateRegion(list)
    break if list.length == oldLength
    oldLength = list.length
  return list

# All commands in the same layer are equal, but the same as dependency
# command need to be moved to the top, so it can be aggregated in the flat
# array
module.exports.bumpDependency = (list, dependency) ->
  aggregator = dependency.constructor.aggregator()
  for c, i in list
    if aggregator.equals(c.constructor.aggregator())
      circular = list[0..i]
      circular.unshift(circular.pop())
      list[0..i] = circular
      break
