MultiRun = require '../lib/commands/multi-run'
var Dockerfile = require '../lib/dockerfile'

class PrintWords
  @aggregator: () -> MultiRun.aggregator()
  getWords: (arg) ->
    if arg instanceof PrintWord
      arg.word
    else
      arg.words.join(' ')
  constructor: (args...) ->
    @run = 'echo "' + (@getWords(arg) for arg in args).join(' ') + '"'
  overrides: () -> false

class Aggregator
  aggregator: () -> PrintWords.aggregator()
  equals: (what) -> what instanceof PrintWord or what instanceof PrintWords
  aggregate: (args...) -> new PrintWords(args...)

class PrintWord
  @aggregator: () -> new Aggregator()
  constructor: (@word) ->
  overrides: () -> false

describe 'Aggregate', () ->
  it 'multiple levels', () ->
    dockerfile = new Dockerfile()
    dockerfile.add(new PrintWord('first'))
    dockerfile.add(new PrintWord('second'))
    dockerfile.add(new PrintWord('third'))
    dockerfile.add(new PrintWord('fourth'))
    dockerfile.add(new PrintWord('fifth'))
    lines = []
    dockerfile.build(lines)
    should(lines[0]).be.equal('echo "first second third fourth fifth"')
  });
});
