Label = require('./label')

class MultiLabel
  constructor: (labels...) ->
    throw new Error('Labels is mandatory') unless labels.length > 0
    @labels = []
    for label in labels
      if label instanceof Label
        @labels.push(label)
      else if label instanceof MultiLabel
        @labels = @labels.concat(label.labels)
      else
        throw new Error('All arguments must be Label or MultiLabel')
  keyword: -> 'LABEL'
  toString: ->
    @keyword() + ' ' +
    ("\"#{label.name}\"=\"#{label.value}\"" for label in @labels).join(' ')
  combines: -> true
  overrides: -> false

module.exports = MultiLabel
