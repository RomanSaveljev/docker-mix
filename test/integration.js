var DockerMix = require('../index.js');
var should = require('should');

describe('Module', function() {
  it('loads', function() {
    should(DockerMix).be.ok();
  });
  it('Dockerfile is OK', function() {
    should(DockerMix.Dockerfile).be.ok();
  });
  it('Cmd is OK', function() {
    should(DockerMix.Cmd).be.ok();
  });
  it('Copy is OK', function() {
    should(DockerMix.Copy).be.ok();
  });
  it('Entrypoint is OK', function() {
    should(DockerMix.Entrypoint).be.ok();
  });
  it('Env is OK', function() {
    should(DockerMix.Env).be.ok();
  });
  it('Expose is OK', function() {
    should(DockerMix.Expose).be.ok();
  });
  it('From is OK', function() {
    should(DockerMix.From).be.ok();
  });
  it('Label is OK', function() {
    should(DockerMix.Label).be.ok();
  });
  it('Maintainer is OK', function() {
    should(DockerMix.Maintainer).be.ok();
  });
  it('Run is OK', function() {
    should(DockerMix.Run).be.ok();
  });
  it('User is OK', function() {
    should(DockerMix.User).be.ok();
  });
  it('Volume is OK', function() {
    should(DockerMix.Volume).be.ok();
  });
  it('Workdir is OK', function() {
    should(DockerMix.Workdir).be.ok();
  });
  it('Nop is OK', function() {
    should(DockerMix.Nop).be.ok();
  });
  it('Comment is OK', function() {
    should(DockerMix.Comment).be.ok();
  });
});
