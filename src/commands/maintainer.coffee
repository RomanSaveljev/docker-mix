class Maintainer
  constructor: (@maintainer) ->
    throw new Error('Must pass maintainer name') unless @maintainer
  toString: -> "#{@keyword()} #{@maintainer}"
  keyword: -> "MAINTAINER"
  toString: -> "#{@keyword()} #{@maintainer}"
  combines: (command) -> false
  overrides: (command) -> true

module.exports = Maintainer
