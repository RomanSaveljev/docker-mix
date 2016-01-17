MultiExpose = require './multi-expose'

class Expose
  @aggregator: () -> MultiExpose.aggregator()
  constructor: (@port) ->
    throw new Error("Port number is mandatory") unless @port?
  overrides: -> false

module.exports = Expose
