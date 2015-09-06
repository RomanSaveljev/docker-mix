Run = require('./run')

class MultiRun
  constructor: (runs...) ->
    throw new Error('Runs is mandatory') unless runs.length > 0
    @runs = []
    for r in runs
      if r instanceof Run
        @runs.push(r)
      else if r instanceof MultiRun
        @runs = @runs.concat(r.runs)
      else
        throw new Error('All arguments must be Runs or MultiRuns')
  applyTo: (context, dockerfile) ->
    dockerfile.push('RUN ' + (r.run for r in @runs).join(' && '))

module.exports = MultiRun
