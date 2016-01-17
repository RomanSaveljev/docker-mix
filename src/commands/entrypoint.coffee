NullAggregator = require('./null-aggregator')

class Entrypoint
  @aggregator: () -> new NullAggregator()
  constructor: (entrypoint, args...) ->
    if args.length > 0
      # exec form
      @entrypoint = [entrypoint]
      @entrypoint = @entrypoint.concat(args)
    else
      # shell form
      @entrypoint = entrypoint
  applyTo: (context, dockerfile) ->
    dockerfile.push('ENTRYPOINT ' + (if typeof @entrypoint == 'string' then @entrypoint else JSON.stringify(@entrypoint)))
  overrides: -> true

module.exports = Entrypoint
