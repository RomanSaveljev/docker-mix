var Env = require('../../lib/commands/env');
var should = require('should');

describe('Env', function() {
  it('has ENV keyword', function() {
    var env = new Env('a', 'b');
    should(env.keyword()).be.equal('ENV');
  });
  it('combines', function() {
    var env = new Env('a', 'b');
    should(env.combines()).be.true();
  });
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
  it('formats both name and value', function() {
    var env = new Env('name', 'some value');
    should(env.toString()).be.equal('ENV "name" some value');
  });
});
