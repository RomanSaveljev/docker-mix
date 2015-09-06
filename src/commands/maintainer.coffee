class Maintainer
  constructor: (@maintainer) ->
    throw new Error('Must pass maintainer name') unless @maintainer
  applyTo: (context, dockerfile) ->
    dockerfile.push("MAINTAINER #{@maintainer}")
  overrides: (command) -> true

module.exports = Maintainer
