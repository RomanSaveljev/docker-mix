var MultiEnv = require('../../lib/commands/multi-env');
var should = require('should');
var Env = require('../../lib/commands/env');

describe('MultiEnv', function() {
  var env = new Env('a', 'b');
  it('has ENV keyword', function() {
    var multiEnv = new MultiEnv(env);
    should(multiEnv.keyword()).be.equal('ENV');
  });
  it('combines', function() {
    var multiEnv = new MultiEnv(env);
    should(multiEnv.combines()).be.true();
  });
  it('does not override', function() {
    var multiEnv = new MultiEnv(env);
    should(multiEnv.overrides()).be.false();
  });
  it('constructor throws without parameters', function() {
    should(function() {new MultiEnv()}).throw();
  });
  it('constructor expects parameters to be Env or MultiEnv', function() {
    should(function() {new MultiEnv(8)}).throw();
    should(function() {new MultiEnv(env)}).not.throw();
    should(function() {new MultiEnv(new MultiEnv(env))}).not.throw();
  });
  it('renders all environment variables included', function() {
    var env2 = new Env('c', 'd');
    var env3 = new Env('e', 'f');
    var multiEnv = new MultiEnv(env2, env3);
    var multiEnv2 = new MultiEnv(multiEnv, env);
    should(multiEnv2.toString()).be.equal('ENV "c"="d" "e"="f" "a"="b"');
  });
});
