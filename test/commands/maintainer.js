var Maintainer = require('../../lib/commands/maintainer');
var should = require('should');

describe('Maintainer', function() {
  it('has MAINTAINER keyword', function() {
    var maintainer = new Maintainer('me');
    should(maintainer.keyword()).be.equal('MAINTAINER');
  });
  it('constructor throws without arguments', function() {
    should(function() {new Maintainer()}).throw();
  });
  it('assigns maintainer', function() {
    var maintainer = new Maintainer('John Doe');
    should(maintainer.maintainer).be.equal('John Doe');
  });
  it('uses maintainer in toString()', function() {
    var maintainer = new Maintainer('Abby Foo');
    should(maintainer.toString()).be.equal('MAINTAINER Abby Foo');
  });
  it('does not combine', function() {
    var maintainer = new Maintainer('someone');
    should(maintainer.combines()).be.false();
  });
  it('overrides', function() {
    var maintainer = new Maintainer('someone');
    should(maintainer.overrides()).be.true();
  });
});
