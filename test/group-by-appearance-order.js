var groupByAppearanceOrder = require('../lib/group-by-appearance-order');
var should = require('should')

function A() {
  this.is = 'A';
}

function B() {
  this.is = 'B';
}

function C() {
  this.is = 'C';
}

describe('GroupByAppearanceOrder', function() {
  it('works', function() {
    var array = [new A(), new B(), new C(), new A(), new C(), new B()];
    var sorted = groupByAppearanceOrder(array);
    should(sorted[0]).be.instanceof(A);
    should(sorted[1]).be.instanceof(A);
    should(sorted[2]).be.instanceof(B);
    should(sorted[3]).be.instanceof(B);
    should(sorted[4]).be.instanceof(C);
    should(sorted[5]).be.instanceof(C);
  });
  it('simple', function() {
    var array = [new A(), new B(), new A(), new A()];
    var sorted = groupByAppearanceOrder(array);
    should(sorted[0]).be.instanceof(A);
    should(sorted[1]).be.instanceof(A);
    should(sorted[2]).be.instanceof(A);
    should(sorted[3]).be.instanceof(B);
  });
});
