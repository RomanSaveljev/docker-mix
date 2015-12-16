var Workdir = require('../../lib/commands/workdir');
var should = require('should');

describe('Workdir', function() {
  var dockerfile = [];
  it('constructor throws without arguments', function() {
    should(function() {new Workdir()}).throw();
  });
  it('uses workdir in applyTo()', function() {
    var workdir = new Workdir("/1/2");
    workdir.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('WORKDIR /1/2');
  });
  it('does not override', function() {
    var workdir = new Workdir('/a');
    should(workdir.overrides()).be.false();
  });
});
