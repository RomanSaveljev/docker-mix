Volume = require('./volume')

class MultiVolume
  constructor: (volumes...) ->
    throw new Error('Volumes is mandatory') unless volumes.length > 0
    @volumes = []
    for v in volumes
      if v instanceof Volume
        @volumes.push(v)
      else if v instanceof MultiVolume
        @volumes = @volumes.concat(v.volumes)
      else
        throw new Error('All arguments must be Volume or MultiVolume')
  applyTo: (context, dockerfile) ->
    if @volumes.length == 1
      dockerfile.push("VOLUME #{@volumes[0].volume}")
    else if @volumes.length > 1
      dockerfile.push('VOLUME ' + JSON.stringify((v.volume for v in @volumes)))

module.exports = MultiVolume
