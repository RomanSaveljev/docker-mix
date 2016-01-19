var functions = require('../lib/dockerfile-functions');
var should = require('should');
var Run = require('../lib/commands/run');
var MultiRun = require('../lib/commands/multi-run');
var Expose = require('../lib/commands/expose');
var MultiExpose = require('../lib/commands/multi-expose');
var NullAggregator = require('../lib/commands/null-aggregator');
var User = require('../lib/commands/user')

function prepareCommand(cmd) {
  cmd.next = [];
  return cmd;
}

function DummyStatement() {
}

DummyStatement.aggregator = function() {
  return new NullAggregator();
}

describe('AggregateRest', function() {
  var dockerfile = [];
  it('returns next index to check, if first element type can not be combined', function() {
    var list = [new DummyStatement(), new Run('echo 123')];
    var index = functions.aggregateRest(list, 0);
    should(index).be.equal(1);
    should(list.length).be.equal(2);
  });
  it('single combinable command becomes multi-command', function() {
    var command = new Run('echo 123');
    var list = [command];
    functions.aggregateRest(list, 0);
    should(list.length).be.equal(1);
    should(list[0]).be.instanceof(MultiRun);
  });
  it('collects together combinable commands', function() {
    var command = new Run('echo 123');
    var command2 = new Run('echo 456');
    var list = [command, command2];
    functions.aggregateRest(list, 0);
    should(list.length).be.equal(1);
    should(list[0]).be.instanceof(MultiRun);
    var dockerfile = [];
    list[0].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 123 && echo 456');
  });
  it('collects until the first different command', function() {
    var command = new Run('echo 123');
    var command2 = new Expose(12);
    var list = [command, command2];
    functions.aggregateRest(list, 0);
    should(list.length).be.equal(2);
    should(list[0]).be.instanceof(MultiRun);
    list[0].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 123');
    should(list[1]).be.equal(command2);
  });
});

describe('Aggregate', function() {
  it('aggregates all regions', function() {
    var command = new Run('echo 123');
    var command2 = new Run('echo 456');
    var command3 = new Expose(56);
    var command4 = new Expose(57);
    var list = [command, command2, command3, command4];
    functions.aggregate(list, 0);
    should(list.length).be.equal(2);
    should(list[0]).be.instanceof(MultiRun);
    list[0].applyTo(new DummyStatement(), dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 123 && echo 456');
    should(list[1]).be.instanceof(MultiExpose);
    list[1].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('EXPOSE 56 57');
  });
  it('command followed by multi-command', function() {
    var list = [
      new Run('echo 123'),
      new MultiRun(new Run('echo 456'))
    ];
    functions.aggregate(list, 0);
    should(list.length).be.equal(1);
    list[0].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 123 && echo 456');
  });
  it('multi-command followed by command', function() {
    var list = [
      new MultiRun(new Run('echo 456')),
      new Run('echo 123')
    ];
    functions.aggregate(list, 0);
    should(list.length).be.equal(1);
    list[0].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 456 && echo 123');
  });
  it('multi-command, command, multi-command', function() {
    var list = [
      new MultiRun(new Run('echo 456')),
      new Run('echo 123'),
      new MultiRun(new Run('echo 789')),
    ];
    functions.aggregate(list, 0);
    should(list.length).be.equal(1);
    list[0].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 456 && echo 123 && echo 789');
  });
  it('command, multi-command, command', function() {
    var list = [
      new Run('echo 456'),
      new MultiRun(new Run('echo 123')),
      new Run('echo 789'),
    ];
    functions.aggregate(list, 0);
    should(list.length).be.equal(1);
    list[0].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 456 && echo 123 && echo 789');
  });
});

describe('BumpDependency', function() {
  it('bumps a combinable command to the top of the list', function() {
    var command = new Run('echo 123');
    var command2 = new Expose(56);
    var list = [command, command2];
    functions.bumpDependency(list, command2);
    should(list[0]).be.instanceof(Expose);
  });
  it('bumps a combinable command closer to its multi-command', function() {
    var command = new Run('echo 123');
    var command2 = new Expose(56);
    var multi = new MultiExpose(new Expose(78))
    var list = [command, command2];
    functions.bumpDependency(list, multi);
    should(list[0]).be.instanceof(Expose);
  });
});
