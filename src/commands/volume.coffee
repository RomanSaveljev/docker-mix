class Volume
  constructor: (@volume) ->
    throw new Error('Volume is mandatory') unless @volume?
  keyword: -> "VOLUME"
  toString: -> "#{@keyword()} #{@volume}"
  combines: -> true
  overrides: -> false

module.exports = Volume
