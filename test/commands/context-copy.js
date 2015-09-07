var ContextCopy = require('../../lib/commands/context-copy');
var should = require('should');

describe('ContextCopy', function() {
  it('constructor throws without arguments', function() {
    should(function() {new ContextCopy()}).throw();
  });
  it('does not override', function() {
    var copy = new ContextCopy(function() {});
    should(copy.overrides()).be.false();
  });
  it('applyTo() calls callback', function() {
    var context = {a: 2};
    var callbackCalled = false;
    var callback = function(cnx) {
      should(cnx).be.equal(context);
      callbackCalled = true;
    };
    var copy = new ContextCopy(callback);
    copy.applyTo(context);
    should(callbackCalled).be.true();
  });
});
