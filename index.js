var DockerMix = {
  Dockerfile: require('./lib/dockerfile'),
  Add: require('./lib/commands/add'),
  Cmd: require('./lib/commands/cmd'),
  Copy: require('./lib/commands/copy'),
  Entrypoint: require('./lib/commands/entrypoint'),
  Env: require('./lib/commands/env'),
  Expose: require('./lib/commands/expose'),
  From: require('./lib/commands/from'),
  Label: require('./lib/commands/label'),
  Maintainer: require('./lib/commands/maintainer'),
  Run: require('./lib/commands/run'),
  User: require('./lib/commands/user'),
  Volume: require('./lib/commands/volume'),
  Workdir: require('./lib/commands/workdir')
};

module.exports = DockerMix;
