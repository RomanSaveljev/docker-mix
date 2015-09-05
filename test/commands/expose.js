var Expose = require('../../lib/commands/expose');
var should = require('should');

describe('Expose', function() {
  it('has EXPOSE keyword', function() {
    var expose = new Expose(4560);
    should(expose.keyword()).be.equal('EXPOSE');
  });
  it('combines', function() {
    var expose = new Expose(1234);
    should(expose.combines()).be.true();
  });
  it('does not override', function() {
    var expose = new Expose(48);
    should(expose.overrides()).be.false();
  });
  it('constructor throws, when no parameters', function() {
    should(function() {new Expose()}).throw();
  });
  it('formats port number', function() {
    var expose = new Expose(1467);
    should(expose.toString()).be.equal('EXPOSE 1467');
  });
});
