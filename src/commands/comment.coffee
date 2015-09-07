class Comment
  constructor: (@comment) ->
    throw new Error('Comment is mandatory') unless @comment?
  applyTo: (context, dockerfile) ->
    dockerfile.push("# #{@comment}")
  overrides: -> false

module.exports = Comment
