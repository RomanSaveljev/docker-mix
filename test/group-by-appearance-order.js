var groupByAppearanceOrder = require('../lib/group-by-appearance-order');
var should = require('should')
var Run = require('../lib/commands/run');
var Expose = require('../lib/commands/expose');
var Env = require('../lib/commands/env');

describe('GroupByAppearanceOrder', function() {
  it('works', function() {
    var array = [
      new Run('true'),
      new Expose(45),
      new Env('a', 'b'),
      new Run('false'),
      new Env('c', 'd'),
      new Expose(78)
    ];
    var sorted = groupByAppearanceOrder(array);
    should(sorted[0]).be.instanceof(Run);
    should(sorted[1]).be.instanceof(Run);
    should(sorted[2]).be.instanceof(Expose);
    should(sorted[3]).be.instanceof(Expose);
    should(sorted[4]).be.instanceof(Env);
    should(sorted[5]).be.instanceof(Env);
  });
  it('simple', function() {
    var array = [
      new Run('true'),
      new Expose(12),
      new Run('false'),
      new Run(':')
    ];
    var sorted = groupByAppearanceOrder(array);
    should(sorted[0]).be.instanceof(Run);
    should(sorted[1]).be.instanceof(Run);
    should(sorted[2]).be.instanceof(Run);
    should(sorted[3]).be.instanceof(Expose);
  });
});
