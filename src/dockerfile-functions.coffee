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

module.exports.sameCommand = (a, b) -> sameType(a, b.constructor)

module.exports.combinesTo = (type) ->
  switch type
    when Env, MultiEnv then return MultiEnv
    when Expose, MultiExpose then return MultiExpose
    when Label, MultiLabel then return MultiLabel
    when Run, MultiRun then return MultiRun
    when Volume, MultiVolume then return MultiVolume
    when ContextCopy, MultiContextCopy then return MultiContextCopy
    else return undefined

module.exports.aggregateRegion = (list, index) ->
  next = index + 1
  # Index should point at the beginning of a suitable region
  type = list[index].constructor
  ctor = module.exports.combinesTo(type)
  return next unless ctor?
  # Every combinable command becomes a multi-command (with a potential to collect
  # more than one command)
  aggregated = new ctor(list[index])
  aggregated.next = list[index].next
  list[index] = aggregated
  return next unless list[index].next.length == 0
  while list.length > next
    return next if module.exports.combinesTo(list[next].constructor) != ctor or list[next].next.length != 0
    aggregate = new ctor(list[index], list[next])
    aggregate.next = list[index].next
    list[index] = aggregate
    list[(next)..(next)] = []
  return next

# Updates the list in-place, handles continuous regions
module.exports.aggregate = (list) ->
  index = 0
  while (index < list.length)
    index = module.exports.aggregateRegion(list, index)
  return list
