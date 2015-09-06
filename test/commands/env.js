var Env = require('../../lib/commands/env');
var should = require('should');

describe('Env', function() {
  it('does not override', function() {
    var env = new Env('a', 'b');
    should(env.overrides()).be.false();
  });
  it('constructor throws, when no parameters', function() {
    should(function() {new Env()}).throw();
  });
  it('constructor throws, when one parameter', function() {
    should(function() {new Env('c')}).throw();
  });
});
