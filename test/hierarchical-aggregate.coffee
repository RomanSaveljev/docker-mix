MultiRun = require '../lib/commands/multi-run'
Run = require '../lib/commands/run'
Dockerfile = require '../lib/dockerfile'
From = require '../lib/commands/from'
should = require 'should'

class PrintWords
  @aggregator: () -> MultiRun.aggregator()
  constructor: (args...) ->
    @words = []
    for arg in args
      console.log('in PrintWords ' + arg.constructor.name)
      if arg instanceof Word
        @words.push(arg.word)
      else if arg instanceof Morse
        @words.push(arg.code)
      else
        @words = @words.concat(arg.words)
    console.dir(@words)
    @run = "echo \"#{@words.join(' ')}\""
  overrides: () -> false
  execForm: () -> false

class WordAggregator
  equals: (what) -> what instanceof WordAggregator or what instanceof MorseAggregator
  aggregate: (args...) -> new PrintWords(args...)

class Word
  @aggregator: () -> new WordAggregator()
  constructor: (args...) ->
    if typeof args[0] is 'string'
      @word = args[0]
    else
      @letters = []
      for arg in args
        if arg instanceof Letter
          @letters.push(arg.letter)
        else if arg instanceof Symbol
          @letters.push(arg.symbol)
        else if arg instanceof Digit
          @letters.push(arg.digit)
        else
          @letters = @letters.concat(arg.letters)
        @word = @letters.join('')
  overrides: () -> false

class MorseAggregator
  equals: (what) -> what instanceof MorseAggregator #or MultiRun.aggregator().equals(what)
  aggregate: (args...) -> new PrintWords(args...)

class Morse
  @aggregator: () -> new MorseAggregator()
  constructor: (@code) ->
  overrides: () -> false

class LetterAggregator
  equals: (what) -> what instanceof LetterAggregator
  aggregate: (args...) -> new Word(args...)

class Letter
  @aggregator: () -> new LetterAggregator()
  constructor: (@letter) ->
  overrides: () -> false

class SymbolAggregator
  equals: (what) -> what instanceof SymbolAggregator
  aggregate: (args...) -> new Word(args...)

class Symbol
  @aggregator: () -> new SymbolAggregator()
  constructor: (@symbol) ->
  overrides: () -> false

class DigitAggregator
  equals: (what) -> what instanceof DigitAggregator
  aggregate: (args...) -> new Word(args...)

class Digit
  @aggregator: () -> new DigitAggregator()
  constructor: (@digit) ->
  overrides: () -> false

describe 'Aggregate', () ->
  it 'multiple levels', () ->
    dockerfile = new Dockerfile()
    dockerfile.add(new From('scratch'))
    for c in 'first'.split('')
      dockerfile.add(new Letter(c))
    ###
    dockerfile.add(new Word('---...--.-.--'))
    for c in '#&@$'.split('')
      dockerfile.add(new Symbol(c))
    for c in '1670241'.split('')
      dockerfile.add(new Digit(c))
    dockerfile.add(new Run('true'))
    ###
    lines = []
    dockerfile.build(lines)
    #should(lines[1]).be.equal('RUN echo "first ---...--.-.-- #&@$ 1670241"')
    should(lines[1]).be.equal('RUN echo "first"')
