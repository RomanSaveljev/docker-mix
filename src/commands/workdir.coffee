class Workdir
  constructor: (@workdir) ->
    throw new Error('Workdir is mandatory') unless @workdir?
  applyTo: (context, dockerfile) ->
    dockerfile.push("WORKDIR #{@workdir}")
  overrides: -> true

module.exports = Workdir
