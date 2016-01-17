class Aggregator
  constructor: () ->
    @id = 'MULTI_RUN_AGGREGATE'
  aggregator: () -> @
  equals: (what) -> what.id? and what.id is @id
  aggregate: (args...) -> new MultiRun(args...)

class MultiRun
  @aggregator: () -> new Aggregator()
  constructor: (runs...) ->
    throw new Error('Runs is mandatory') unless runs.length > 0
    @runs = []
    aggregator = @constructor.aggregator()
    for r in runs
      unless aggregator.equals(r.constructor.aggregator())
        throw new Error('Does not aggregate to MultiRun')
      if r.runs instanceof Array
        @runs = @runs.concat(r.runs)
      else if r.run?
        @runs.push(r)
      else
        throw new Error('Does not have run property')
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
