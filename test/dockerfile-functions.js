var functions = require('../lib/dockerfile-functions');
var should = require('should');
var Run = require('../lib/commands/run');
var MultiRun = require('../lib/commands/multi-run');
var Expose = require('../lib/commands/expose');
var MultiExpose = require('../lib/commands/multi-expose');

function prepareCommand(cmd) {
  cmd.next = [];
  return cmd;
}

describe('AggregateRegion', function() {
  var dockerfile = [];
  it('returns next index to check, if first element type can not be combined', function() {
    var list = [prepareCommand({}), prepareCommand(new Run('echo 123'))];
    var index = functions.aggregateRegion(list, 0);
    should(index).be.equal(1);
    should(list.length).be.equal(2);
  });
  it('single combinable commands with children become multi-commands', function() {
    var command = prepareCommand(new Run('echo 123'));
    command.next.push({a: 3});
    var list = [command];
    var index = functions.aggregateRegion(list, 0);
    should(index).be.equal(1);
    should(list.length).be.equal(1);
    should(list[0]).be.instanceof(MultiRun);
    should(list[0].next).be.Array();
    should(list[0].next).be.equal(command.next);
  });
  it('single combinable commands without children become multi-commands', function() {
    var command = prepareCommand(new Run('echo 123'));
    var list = [command];
    var index = functions.aggregateRegion(list, 0);
    should(index).be.equal(1);
    should(list.length).be.equal(1);
    should(list[0]).be.instanceof(MultiRun);
    should(list[0].next).be.Array();
    should(list[0].next).be.equal(command.next);
    list[0].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 123');
  });
  it('collects together combinable child-free commands', function() {
    var command = prepareCommand(new Run('echo 123'));
    var command2 = prepareCommand(new Run('echo 456'));
    var list = [command, command2];
    var index = functions.aggregateRegion(list, 0);
    should(index).be.equal(1);
    should(list.length).be.equal(1);
    should(list[0]).be.instanceof(MultiRun);
    var dockerfile = [];
    list[0].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 123 && echo 456');
    should(list[0].next).be.Array();
  });
  it('stops collecting at first command with children', function() {
    var command = prepareCommand(new Run('echo 123'));
    var command2 = prepareCommand(new Run('echo 456'));
    command2.next.push({});
    var list = [command, command2];
    var index = functions.aggregateRegion(list, 0);
    should(index).be.equal(1);
    should(list.length).be.equal(2);
    should(list[0]).be.instanceof(MultiRun);
    list[0].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 123');
    should(list[0].next).be.Array();
    should(list[1]).be.equal(command2);
  });
  it('collects until the first different command', function() {
    var command = prepareCommand(new Run('echo 123'));
    var command2 = prepareCommand(new Expose(12));
    var list = [command, command2];
    var index = functions.aggregateRegion(list, 0);
    should(index).be.equal(1);
    should(list.length).be.equal(2);
    should(list[0]).be.instanceof(MultiRun);
    list[0].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 123');
    should(list[0].next).be.Array();
    should(list[1]).be.equal(command2);
  });
  it('combines multi-command with a single command', function() {
    var command = prepareCommand(new MultiRun(new Run('echo 123')));
    var command2 = prepareCommand(new Run('echo 456'));
    var list = [command, command2];
    var index = functions.aggregateRegion(list, 0);
    should(index).be.equal(1);
    should(list.length).be.equal(1);
    should(list[0]).be.instanceof(MultiRun);
    list[0].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 123 && echo 456');
    should(list[0].next).be.Array();
  });
});

describe('Aggregate', function() {
  it('aggregates all regions', function() {
    var command = prepareCommand(new Run('echo 123'));
    var command2 = prepareCommand(new Run('echo 456'));
    var command3 = prepareCommand(new Expose(56));
    var command4 = prepareCommand(new Expose(57));
    var list = [command, command2, command3, command4];
    functions.aggregate(list, 0);
    should(list.length).be.equal(2);
    should(list[0]).be.instanceof(MultiRun);
    list[0].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 123 && echo 456');
    should(list[1]).be.instanceof(MultiExpose);
    list[1].applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('EXPOSE 56 57');
  });
});

describe('BumpDependency', function() {
  it('bumps a combinable command to the top of the list', function() {
    var command = prepareCommand(new Run('echo 123'));
    var command2 = prepareCommand(new Expose(56));
    var list = [command, command2];
    functions.bumpDependency(list, command2);
    should(list[0]).be.instanceof(Expose);
  });
});
