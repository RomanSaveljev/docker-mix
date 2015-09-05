extend = require('extend')

defaults =
  tag: 'latest'

class From
  constructor: (opts) ->
    if typeof opts == 'string'
      extend(@, defaults)
      @image = opts
    else if opts?.image?
      extend(@, defaults, opts)
    else
      throw new Error('Pass image as a string or inside opts')
  toString: ->
    registryName = if @registry? then "#{@registry}/" else ""
    userName = if @user? then "#{@user}/" else ""
    "#{@keyword()} #{registryName}#{userName}#{@image}:#{@tag}"
  keyword: -> "FROM"
  combines: (command) -> false
  overrides: (command) -> true

module.exports = From
