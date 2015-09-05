class Env
  constructor: (@name, @value) ->
    throw new Error('name is a mandatory parameter') unless @name?
    throw new Error('value is a mandatory parameter') unless @value?
  keyword: -> 'ENV'
  toString: -> "#{@keyword()} \"#{@name}\" #{@value}"
  combines: -> true
  overrides: -> false

module.exports = Env
