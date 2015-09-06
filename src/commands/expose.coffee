class Expose
  constructor: (@port) ->
    throw new Error("Port number is mandatory") unless @port?
  overrides: -> false

module.exports = Expose
