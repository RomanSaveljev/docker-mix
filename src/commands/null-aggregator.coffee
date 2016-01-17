class NullAggregator
  aggregator: () -> @
  equals: () -> false
  aggregate: () -> new Object()

module.exports = NullAggregator
