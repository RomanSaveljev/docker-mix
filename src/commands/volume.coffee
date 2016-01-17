MultiVolume = require './multi-volume'

class Volume
  @aggregator: () -> MultiVolume.aggregator()
  constructor: (@volume) ->
    throw new Error('Volume is mandatory') unless @volume?
  overrides: -> false

module.exports = Volume
