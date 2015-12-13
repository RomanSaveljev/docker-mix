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

combinesTo = (type) ->
  switch type
    when Env, MultiEnv then return MultiEnv
    when Expose, MultiExpose then return MultiExpose
    when Label, MultiLabel then return MultiLabel
    when Run, MultiRun then return MultiRun
    when Volume, MultiVolume then return MultiVolume
    when ContextCopy, MultiContextCopy then return MultiContextCopy
    else return undefined

module.exports.combinable = (a, b) ->
  combinesA = combinesTo(a.constructor)
  combinesA? and combinesA is combinesTo(b.constructor)

module.exports.aggregateRegion = (list, index) ->
  next = index + 1
  # Index should point at the beginning of a suitable region
  type = list[index].constructor
  ctor = combinesTo(type)
  return next unless ctor?
  # Every combinable command becomes a multi-command (with a potential to collect
  # more than one command)
  aggregated = new ctor(list[index])
  list[index] = aggregated
  # Add every following command until it does not combine
  while list.length > next
    return next if combinesTo(list[next].constructor) != ctor
    aggregate = new ctor(list[index], list[next])
    list[index] = aggregate
    list[(next)..(next)] = []
  return next

# Updates the list in-place, handles continuous regions
module.exports.aggregate = (list) ->
  index = 0
  while (index < list.length)
    index = module.exports.aggregateRegion(list, index)
  return list

# All commands in the same layer are equal, but the same as dependency
# command need to be moved to the top, so it can be aggregated in the flat
# array
module.exports.bumpDependency = (list, dependency) ->
  for c, i in list
    if module.exports.combinable(c, dependency)
      circular = list[0..i]
      circular.unshift(circular.pop())
      list[0..i] = circular
      break
