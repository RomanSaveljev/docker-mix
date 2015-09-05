class Dockerfile
  constructor: ->
    @commands = []
  add: (command) ->
    @commands.push(command)
