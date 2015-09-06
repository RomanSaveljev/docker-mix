class ExecRun
  constructor: (@run...) ->
    throw new Error('Need some arguments') unless @run.length > 0
  applyTo: (context, dockerfile) ->
    dockerfile.push("RUN #{JSON.stringify(@run)}")
  overrides: (command) -> false

module.exports = ExecRun
