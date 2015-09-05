class Expose
  constructor: (@port) ->
    throw new Error("Port number is mandatory") unless @port?
  keyword: -> 'EXPOSE'
  combines: -> true
  overrides: -> false
  toString: -> "#{@keyword()} #{@port}"

module.exports = Expose
