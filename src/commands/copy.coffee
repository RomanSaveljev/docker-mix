class Copy
  constructor: (@src, @dst) ->
    throw new Error('Src parameter is mandatory') unless @src?
    throw new Error('Dst parameter is mandatory') unless @dst?
  keyword: -> "COPY"
  combines: -> false
  overrides: -> false
  toString: -> "#{@keyword()} #{JSON.stringify([@src, @dst])}"

module.exports = Copy
