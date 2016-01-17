NullAggregator = require './null-aggregator'

class Workdir
  @aggregator: () -> new NullAggregator()
  constructor: (@workdir) ->
    throw new Error('Workdir is mandatory') unless @workdir?
  applyTo: (context, dockerfile) ->
    dockerfile.push("WORKDIR #{@workdir}")
  overrides: -> false

module.exports = Workdir
