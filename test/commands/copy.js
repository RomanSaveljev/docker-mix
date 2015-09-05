var Copy = require('../../lib/commands/copy');
var should = require('should');

describe('Copy', function() {
  it('has COPY keyword', function() {
    var copy = new Copy('a/b/c', '/d/e');
    should(copy.keyword()).be.equal('COPY');
  });
  it('does not combine', function() {
    var copy = new Copy('a/b/c', '/d/e');
    should(copy.combines()).be.false();
  });
  it('does not override', function() {
    var copy = new Copy('a/b/c', '/d/e');
    should(copy.overrides()).be.false();
  });
  it('uses src and dst', function() {
    var copy = new Copy('a/b/c', '/d/e');
    should(copy.toString()).be.equal('COPY ["a/b/c","/d/e"]');
  });
  it('constructor throws without parameters', function() {
    should(function() {new Copy()}).throw();
  });
  it('constructor throws with one parameter', function() {
    should(function() {new Copy('a/b/c')}).throw();
  });
});
