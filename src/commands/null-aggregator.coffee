class NullAggregator
  aggregator: () -> @
  equals: () -> false
  aggregate: (arg, arg2) ->
    throw new Error('NullAggregator does not know how to aggregate more than one object') if arg2?
    return arg

module.exports = NullAggregator
