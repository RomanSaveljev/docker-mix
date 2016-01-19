MultiLabel = require './multi-label'

class Aggregator
  constructor: () ->
    @labelAggregator = 'LABEL_AGGREGATE'
  aggregator: () -> MultiLabel.aggregator()
  equals: (what) -> what.labelAggregator? and what.labelAggregator is @labelAggregator
  aggregate: (args...) ->
    new MultiLabel(args...)

class Label
  @aggregator: () -> new Aggregator()
  constructor: (@name, @value) ->
    throw new Error('name is a mandatory parameter') unless @name?
    throw new Error('value is a mandatory parameter') unless @value?
  overrides: -> false

module.exports = Label
