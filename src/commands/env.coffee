MultiEnv = require './multi-env'

class Aggregator
  constructor: () ->
    @envAggregator = 'ENV_AGGREGATE'
  aggregator: () -> MultiEnv.aggregator()
  equals: (what) -> what.envAggregator? and what.envAggregator is @envAggregator
  aggregate: (args...) ->
    new MultiEnv(args...)

class Env
  @aggregator: () -> new Aggregator()
  constructor: (@name, @value) ->
    throw new Error('name is a mandatory parameter') unless @name?
    throw new Error('value is a mandatory parameter') unless @value?
  overrides: -> false

module.exports = Env
