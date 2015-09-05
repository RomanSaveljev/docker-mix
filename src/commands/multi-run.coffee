Run = require('./run')

class MultiRun
  constructor: (runs...) ->
    throw new Error('Runs is mandatory') unless runs.length > 0
    @runs = []
    for r in runs
      if r instanceof Run
        throw new Error("#{r.toString()} - does not combine") unless r.combines()
        @runs.push(r)
      else if r instanceof MultiRun
        @runs = @runs.concat(r.runs)
      else
        throw new Error('All arguments must be Runs or MultiRuns')
  keyword: -> 'RUN'
  toString: ->
    @keyword() + ' ' +
    (r.run for r in @runs).join(' && ')
  combines: -> true
  overrides: -> false

module.exports = MultiRun
