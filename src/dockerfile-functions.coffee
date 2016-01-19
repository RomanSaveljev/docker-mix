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
  segment = list[index..index]
  # Add every following command until it does not combine
  while list.length > next
    if aggregator.equals(list[next].constructor.aggregator())
      segment.push(list[next])
      list[(next)..(next)] = []
    else
      break
  list[index] = aggregator.aggregate(segment...)
  if aggregator is aggregator.aggregator()
    # The element can not aggregate further
    return next
  else
    # Check whether previous element can aggregate after transform
    #return Math.max(index - 1, 0)
    # TODO: is here for testing
    return 0

aggregableDepth = (aggregator) ->
  counter = 0
  until aggregator.aggregator() is aggregator
    counter += 1
    aggregator = aggregator.aggregator()
  return counter

deepMostAggregableIndex = (list) ->
  index = 0
  deepest = aggregableDepth(list[0].constructor.aggregator())
  for i in [0...list.length]
    depth = aggregableDepth(list[i].constructor.aggregator())
    if deepest < depth
      deepest = depth
      index = i
  return [index, deepest]

# Updates the list in-place, handles continuous regions
module.exports.aggregate = (list) ->
  next = 0
  loop
    [index, deepest] = deepMostAggregableIndex(list)
    # Linear aggregation, when everything has been equalized
    index = next if deepest is 0
    next = module.exports.aggregateRest(list, index)
    break if next >= list.length

# Go through all transformations and check will it become aggregable at all
willItAggregate = (what, aggregator) ->
  loop
    return true if what.equals(aggregator)
    deeper = what.aggregator()
    break if deeper is what
    what = deeper

# All commands in the same layer are equal, but the same as dependency
# command need to be moved to the top, so it can be aggregated in the flat
# array
module.exports.bumpDependency = (list, dependency) ->
  aggregator = dependency.constructor.aggregator()
  for c, i in list
    if willItAggregate(c.constructor.aggregator(), aggregator)
      circular = list[0..i]
      circular.unshift(circular.pop())
      list[0..i] = circular
      break
