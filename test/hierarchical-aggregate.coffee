MultiRun = require '../lib/commands/multi-run'
Run = require '../lib/commands/run'
Dockerfile = require '../lib/dockerfile'
From = require '../lib/commands/from'
should = require 'should'
functions = require '../lib/dockerfile-functions'

class PackageAggregator
  constructor: () -> @packageAggregator = 'PACKAGE_AGGREGATE'
  aggregator: () -> Run.aggregator()
  equals: (what) -> what.packageAggregator? and what.packageAggregator is @packageAggregator
  aggregate: (packages...) ->
    new Run("apt-get -y install #{(p.package for p in packages).join(' ')}")

class Package
  @aggregator: () -> new PackageAggregator()
  constructor: (@package) ->
  overrides: () -> false

class CharacterAggregator
  constructor: () -> @characterAggregator = 'CHARACTER_AGGREGATE'
  aggregator: () -> Package.aggregator()
  equals: (what) -> what.characterAggregator? and what.characterAggregator is @characterAggregator
  aggregate: (chars...) ->
    new Package((c.char for c in chars).join(''))

class Character
  @aggregator: () -> new CharacterAggregator()
  constructor: (@char) ->
  overrides: () -> false

describe 'Aggregate', () ->
  it 'second-level aggregation', () ->
    list = [
      new Package('bc')
      new Package('make')
      new Package('libvirt')
    ]
    functions.aggregate(list, 0)
    should(list.length).be.equal(1)
    dockerfile = []
    list[0].applyTo({}, dockerfile)
    should(dockerfile[0]).be.equal('RUN apt-get -y install bc make libvirt')
  it 'third-level aggregation', () ->
    list = [
      new Character('m')
      new Character('a')
      new Character('k')
      new Character('e')
    ]
    functions.aggregate(list, 0)
    should(list.length).be.equal(1)
    dockerfile = []
    list[0].applyTo({}, dockerfile)
    should(dockerfile[0]).be.equal('RUN apt-get -y install make')
  it 'first-level, second-level mixed', () ->
    list = [
      new Run ('echo 123')
      new Package('make')
      new Run('echo 456')
      new Package('bc')
    ]
    functions.aggregate(list, 0)
    should(list.length).be.equal(1)
    dockerfile = []
    list[0].applyTo({}, dockerfile)
    should(dockerfile[0]).be.equal('RUN echo 123 && apt-get -y install make && echo 456 && apt-get -y install bc')
  it 'first, second, third', () ->
    list = [
      new Run ('echo 123')
      new Package('make')
      new Character('a')
    ]
    functions.aggregate(list, 0)
    should(list.length).be.equal(1)
    dockerfile = []
    list[0].applyTo({}, dockerfile)
    should(dockerfile[0]).be.equal('RUN echo 123 && apt-get -y install make a')
  it 'third, second, first', () ->
    list = [
      new Character('a')
      new Package('make')
      new Run ('echo 123')
    ]
    functions.aggregate(list, 0)
    should(list.length).be.equal(1)
    dockerfile = []
    list[0].applyTo({}, dockerfile)
    should(dockerfile[0]).be.equal('RUN apt-get -y install a make && echo 123')
  it 'first, third, second, third', () ->
    list = [
      new Run('echo 123')
      new Character('a')
      new Package('bc')
      new Character('b')
    ]
    functions.aggregate(list, 0)
    should(list.length).be.equal(1)
    dockerfile = []
    list[0].applyTo({}, dockerfile)
    should(dockerfile[0]).be.equal('RUN echo 123 && apt-get -y install a bc b')
  it 'all levels mixed', () ->
    list = [
      new Character('b')
      new Character('c')
      new Package('make')
      new Character('n')
      new Character('a')
      new Character('n')
      new Character('o')
      new MultiRun(new Run('echo 123'))
      new Package('libvirt')
      new Run('echo 456')
    ]
    functions.aggregate(list, 0)
    should(list.length).be.equal(1)
    dockerfile = []
    list[0].applyTo({}, dockerfile)
    should(dockerfile[0]).be.equal('RUN apt-get -y install bc make nano && echo 123 && apt-get -y install libvirt && echo 456')
