var DockerMix = require('../index.js');
var should = require('should');

describe('Module', function() {
  it('loads', function() {
    should(DockerMix).be.ok();
  });
});
