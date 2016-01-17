MultiLabel = require './multi-label'

class Label
  @aggregator: () -> MultiLabel.aggregator()
  constructor: (@name, @value) ->
    throw new Error('name is a mandatory parameter') unless @name?
    throw new Error('value is a mandatory parameter') unless @value?
  overrides: -> false

module.exports = Label
