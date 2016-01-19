MultiExpose = require './multi-expose'

class Aggregator
  constructor: () ->
    @exposeAggregator = 'EXPOSE_AGGREGATE'
  aggregator: () -> MultiExpose.aggregator()
  equals: (what) -> what.exposeAggregator? and what.exposeAggregator is @exposeAggregator
  aggregate: (args...) ->
    new MultiExpose(args...)

class Expose
  @aggregator: () -> new Aggregator()
  constructor: (@port) ->
    throw new Error("Port number is mandatory") unless @port?
  overrides: -> false

module.exports = Expose
