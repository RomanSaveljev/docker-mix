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
    collector = ''
    for r in @runs
      if r.execForm()
        dockerfile.push(collector) if collector.length > 0
        collector = ''
        dockerfile.push("RUN #{JSON.stringify(r.run)}")
      else
        if collector.length == 0 then collector = "RUN #{r.run}"
        else collector += " && #{r.run}"
    dockerfile.push(collector) if collector.length > 0

module.exports = MultiRun
