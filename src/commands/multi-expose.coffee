Expose = require('./expose')

class MultiExpose
  constructor: (ports...) ->
    throw new Error('Ports is mandatory') unless ports.length > 0
    @ports = []
    for p in ports
      if p instanceof Expose
        @ports.push(p)
      else if p instanceof MultiExpose
        @ports = @ports.concat(p.ports)
      else
        throw new Error('All arguments must be Expose or MultiExpose')
  keyword: -> 'EXPOSE'
  toString: ->
    @keyword() + ' ' +
    ("#{p.port}" for p in @ports).join(' ')
  combines: -> true
  overrides: -> false

module.exports = MultiExpose
