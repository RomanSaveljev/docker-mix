var Expose = require('../../lib/commands/expose');
var should = require('should');

describe('Expose', function() {
  it('does not override', function() {
    var expose = new Expose(48);
    should(expose.overrides()).be.false();
  });
  it('constructor throws, when no parameters', function() {
    should(function() {new Expose()}).throw();
  });
});
