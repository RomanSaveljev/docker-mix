class Aggregator
  constructor: () ->
    @multiLabel = 'MULTI_LABEL_AGGREGATE'
  aggregator: () -> @
  equals: (what) -> what.multiLabel? and what.multiLabel is @multiLabel
  aggregate: (args...) -> new MultiLabel(args...)

class MultiLabel
  @aggregator: () -> new Aggregator()
  constructor: (labels...) ->
    throw new Error('Labels is mandatory') unless labels.length > 0
    @labels = []
    aggregator = @constructor.aggregator()
    for label in labels
      unless aggregator.equals(label.constructor.aggregator())
        throw new Error('Does not aggregate to MultiLabel')
      if label.labels instanceof Array
        @labels = @labels.concat(label.labels)
      else if label.name? and label.value?
        @labels.push(label)
      else
        throw new Error('Does not have name or value property')
  applyTo: (context, dockerfile) ->
    if @labels.length > 0
      dockerfile.push("LABEL " + ("\"#{label.name}\"=\"#{label.value}\"" for label in @labels).join(' '))

module.exports = MultiLabel
