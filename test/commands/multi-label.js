var MultiLabel = require('../../lib/commands/multi-label');
var should = require('should');
var Label = require('../../lib/commands/label');

describe('MultiLabel', function() {
  var dockerfile = [];
  var label = new Label('a', 'b');
  it('constructor throws without parameters', function() {
    should(function() {new MultiLabel()}).throw();
  });
  it('constructor expects parameters to be Label or MultiLabel', function() {
    should(function() {new MultiLabel('abc')}).throw();
    should(function() {new MultiLabel(label)}).not.throw();
    should(function() {new MultiLabel(new MultiLabel(label))}).not.throw();
  });
  it('formats all labels included', function() {
    var label2 = new Label('c', 'd');
    var label3 = new Label('e', 'f');
    var multiLabel = new MultiLabel(label2, label3);
    var multiLabel2 = new MultiLabel(multiLabel, label);
    multiLabel2.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('LABEL "c"="d" "e"="f" "a"="b"');
  });
});
