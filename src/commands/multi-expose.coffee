class Aggregator
  constructor: () ->
    @multiExpose = 'MULTI_EXPOSE_AGGREGATE'
  aggregator: () -> @
  equals: (what) -> what.multiExpose? and what.multiExpose is @multiExpose
  aggregate: (args...) -> new MultiExpose(args...)

class MultiExpose
  @aggregator: () -> new Aggregator()
  constructor: (ports...) ->
    throw new Error('Ports is mandatory') unless ports.length > 0
    @ports = []
    aggregator = @constructor.aggregator()
    for p in ports
      unless aggregator.equals(p.constructor.aggregator())
        throw new Error("Does not aggregate to MultiExpose")
      if p.ports instanceof Array
        @ports = @ports.concat(p.ports)
      else if p.port?
        @ports.push(p)
      else
        throw new Error("Does not have port property")
  applyTo: (context, dockerfile) ->
    dockerfile.push('EXPOSE ' + ("#{p.port}" for p in @ports).join(' '))

module.exports = MultiExpose
