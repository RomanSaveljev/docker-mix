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
    for r in runs
      if r.runs instanceof Array
        @runs = @runs.concat(r.runs)
      else if r.run? and typeof r.execForm is 'function'
        @runs.push(r)
      else
        throw new Error('Does not have run property or execForm method')
  applyTo: (context, dockerfile) ->
    collector = ''
    for r in @runs
      if r.execForm()
        dockerfile.push(collector) if collector.length > 0
        collector = ''
        dockerfile.push("RUN #{JSON.stringify(r.run)}")
      else
        if collector.length == 0 then collector = "RUN #{r.run}"
        else collector += " \\\n && #{r.run}"
    dockerfile.push(collector) if collector.length > 0

module.exports = MultiRun
