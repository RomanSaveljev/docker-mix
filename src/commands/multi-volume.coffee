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
  keyword: -> 'VOLUME'
  toString: ->
    @keyword() + ' ' +
    JSON.stringify((v.volume for v in @volumes))
  combines: -> true
  overrides: -> false

module.exports = MultiVolume
