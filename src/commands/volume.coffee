MultiVolume = require './multi-volume'

class Aggregator
  constructor: () ->
    @volumeAggregator = 'VOLUME_AGGREGATE'
  aggregator: () -> MultiVolume.aggregator()
  equals: (what) -> what.volumeAggregator? and what.volumeAggregator is @volumeAggregator
  aggregate: (args...) ->
    new MultiVolume(args...)

class Volume
  @aggregator: () -> new Aggregator()
  constructor: (@volume) ->
    throw new Error('Volume is mandatory') unless @volume?
  overrides: -> false

module.exports = Volume
