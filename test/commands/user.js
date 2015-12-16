var User = require('../../lib/commands/user');
var should = require('should');

describe('User', function() {
  var dockerfile = [];
  it('constructor throws without arguments', function() {
    should(function() {new User()}).throw();
  });
  it('uses user in applyTo()', function() {
    var user = new User(112);
    user.applyTo({}, dockerfile)
    should(dockerfile.pop()).be.equal('USER 112');
  });
  it('does not override', function() {
    var user = new User('someone');
    should(user.overrides()).be.false();
  });
});
