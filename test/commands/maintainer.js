var Maintainer = require('../../lib/commands/maintainer');
var should = require('should');

describe('Maintainer', function() {
  var dockerfile = [];
  it('constructor throws without arguments', function() {
    should(function() {new Maintainer()}).throw();
  });
  it('uses maintainer in applyTo()', function() {
    var maintainer = new Maintainer('Abby Foo');
    maintainer.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('MAINTAINER Abby Foo');
  });
  it('overrides', function() {
    var maintainer = new Maintainer('someone');
    should(maintainer.overrides()).be.true();
  });
});
