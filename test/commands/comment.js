var Comment = require('../../lib/commands/comment');
var should = require('should');

describe('Comment', function() {
  describe('constructor', function() {
    it('throws without parameters', function() {
      should(function() {new Comment()}).throw();
    });
  });
  it('does not override', function() {
    var comment = new Comment('a comment');
    should(comment.overrides()).be.false();
  });
  it('applyTo()', function() {
    dockerfile = [];
    var comment = new Comment('a comment');
    comment.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('# a comment');
  });
  it('aggregator does not aggregate', function() {
    var aggrOne = Comment.aggregator();
    var aggrTwo = Comment.aggregator();
    should(aggrOne.equals(aggrTwo)).be.False();
  })
});
