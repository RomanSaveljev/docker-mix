class Workdir
  constructor: (@workdir) ->
    throw new Error('Workdir is mandatory') unless @workdir?
  keyword: -> 'WORKDIR'
  combines: -> false
  overrides: -> true
  toString: -> "#{@keyword()} #{@workdir}"

module.exports = Workdir
