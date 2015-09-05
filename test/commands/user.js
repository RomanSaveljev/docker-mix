var User = require('../../lib/commands/user');
var should = require('should');

describe('User', function() {
  it('has USER keyword', function() {
    var user = new User('me');
    should(user.keyword()).be.equal('USER');
  });
  it('constructor throws without arguments', function() {
    should(function() {new User()}).throw();
  });
  it('assigns user', function() {
    var user = new User('alaska');
    should(user.user).be.equal('alaska');
  });
  it('uses user in toString()', function() {
    var user = new User(112);
    should(user.toString()).be.equal('USER 112');
  });
  it('does not combine', function() {
    var user = new User('someone');
    should(user.combines()).be.false();
  });
  it('overrides', function() {
    var user = new User('someone');
    should(user.overrides()).be.true();
  });
});
