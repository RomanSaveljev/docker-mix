NullAggregator = require('./null-aggregator')

extend = require('extend')

defaults =
  tag: 'latest'

class From
  @aggregator: () -> new NullAggregator()
  constructor: (opts, tag) ->
    if typeof opts == 'string'
      extend(@, defaults)
      @image = opts
      @tag = tag if tag?
    else if opts?.image?
      extend(@, defaults, opts)
    else
      throw new Error('Pass image as a string or inside opts')
  applyTo: (context, dockerfile) ->
    registryName = if @registry? then "#{@registry}/" else ""
    userName = if @user? then "#{@user}/" else ""
    dockerfile.push("FROM #{registryName}#{userName}#{@image}:#{@tag}")
  overrides: (command) -> true

module.exports = From
