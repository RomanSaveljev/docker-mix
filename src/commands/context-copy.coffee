###
  This command will allow its user to copy data into the context, from where it
  will be transferred to the image filesystem. User passes a callback, which will
  be invoked to apply necessary modifications to the context.
###

MultiContextCopy = require './multi-context-copy'

class ContextCopy
  @aggregator: () -> MultiContextCopy.aggregator()
  constructor: (@callback) ->
    throw new Error("Callback is mandatory") unless @callback?
  applyTo: (context) -> @callback(context)
  overrides: -> false

module.exports = ContextCopy
