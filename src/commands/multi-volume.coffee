class Aggregator
  constructor: () ->
    @multiVolume = 'MULTI_VOLUME_AGGREGATE'
  aggregator: () -> @
  equals: (what) -> what.multiVolume? and what.multiVolume is @multiVolume
  aggregate: (args...) -> new MultiVolume(args...)

class MultiVolume
  @aggregator: () -> new Aggregator()
  constructor: (volumes...) ->
    throw new Error('Volumes is mandatory') unless volumes.length > 0
    @volumes = []
    aggregator = @constructor.aggregator()
    for v in volumes
      unless aggregator.equals(v.constructor.aggregator())
        throw new Error('Does not aggregate to MultiVolume')
      if v.volumes instanceof Array
        @volumes = @volumes.concat(v.volumes)
      else if v.volume?
        @volumes.push(v)
      else
        throw new Error('Does not have volume property')
  applyTo: (context, dockerfile) ->
    if @volumes.length == 1
      dockerfile.push("VOLUME #{@volumes[0].volume}")
    else if @volumes.length > 1
      dockerfile.push('VOLUME ' + JSON.stringify((v.volume for v in @volumes)))

module.exports = MultiVolume
