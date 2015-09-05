var Workdir = require('../../lib/commands/workdir');
var should = require('should');

describe('Workdir', function() {
  it('has WORKDIR keyword', function() {
    var workdir = new Workdir('me');
    should(workdir.keyword()).be.equal('WORKDIR');
  });
  it('constructor throws without arguments', function() {
    should(function() {new Workdir()}).throw();
  });
  it('assigns workdir', function() {
    var workdir = new Workdir('/a/b');
    should(workdir.workdir).be.equal('/a/b');
  });
  it('uses workdir in toString()', function() {
    var workdir = new Workdir("/1/2");
    should(workdir.toString()).be.equal('WORKDIR /1/2');
  });
  it('does not combine', function() {
    var workdir = new Workdir('/a');
    should(workdir.combines()).be.false();
  });
  it('overrides', function() {
    var workdir = new Workdir('/a');
    should(workdir.overrides()).be.true();
  });
});
