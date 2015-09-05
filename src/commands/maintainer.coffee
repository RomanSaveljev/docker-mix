class Maintainer
  constructor: (@maintainer) ->
  toString: -> "#{@keyword()} #{@maintainer}"
  keyword: -> "MAINTAINER"
  combines: (command) -> false
  overrides: (command) -> true

module.exports = Maintainer
