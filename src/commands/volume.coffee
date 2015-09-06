class Volume
  constructor: (@volume) ->
    throw new Error('Volume is mandatory') unless @volume?
  overrides: -> false

module.exports = Volume
