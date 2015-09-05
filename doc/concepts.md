# DockerScript

The project offers a JavaScript library to build an optimized
[Dockerfile](https://docs.docker.com/reference/builder/).

## Scope of the problem

We wanted to create a testable and a reproducible collection of docker images.
Dockerfile syntax offers a simple inheritance pattern, where a new image can begin
putting layers on top of the old image. We also wanted to create a continuous
delivery setup, where every built image would be tested and released.

Over the time we have realized that some fundamental docker design decisions
stop us from creating a truly flexible system:

* Dockerfiles are static, they can not be tuned dynamically to user's needs
* Image hierarchies do not support mixins and it is not easy to relocate the
hierarchy onto a different base image
* Image hierarchy has to be planned to account for all possible descendants -
if a descendant needs to change existing behavior it will create additional layers
* Many intermediate images were not directly usable, but generated significant clutter

Apparently, these are not docker issues. Rather, we perceived the tool wrongly.
After all, it was evident that the problem domain needs to be dealt with outside
of docker.

## Goals

* Generate a single optimized Dockerfile to build the final image from a published
base
* Minimize the number of layers by combining commands together (e.g. set multiple
  environment variables together)
* Do not create extra layers for conflicting commands (e.g. there may be only
  one working directory)
* Encapsulate best practices behind the API (e.g. sort list of installed packages
  alphabetically)
* Limited support for dependencies (e.g. add custom repository before installing
  the package)
* Simple customization
* Common context - all files to be added into the image are combined in a local
  context first and then copied in a single layer

These goals somewhat restrict certain fancy features. For instance, it would be
no longer possible to switch a user in one layer, run some commands and then switch
to another again.

## Workflow

User writes a script, where they consequently call functions to add commands to
a Dockerfile. Dockerfile along with context are returned in a `.tar` archive to
the user. User may review the result or pipe it directly into the build command.

Reusable parts of the Dockerfile can be separated into their own modules.

## Context management

User may add their own files to the container's filesystem. This is easy to optimize
by pre-making the context locally. This once again robs a user of some fanciness.

To manage a context we may have to commission a temporary folder or do it in
memory. We can use [tar-stream](https://www.npmjs.com/package/tar-stream) to keep
the context in memory.

`COPY` and `ADD` are commands, which modify the context. They do not accept multiple
source files/folders. They accept a single pathname or readable stream object.
`ADD` and `COPY` are different in how they handle archives. `ADD` will unpack the
contents under the destination path and `COPY` will copy it over. `ADD` with URL
source is not supported as it is discouraged by best practices guide.

## Dependencies

The commitment to support dependencies for proper ordering of Dockerfile commands
is a serious challenge. The tool must understand what is command's side-effect.

Arranging dependencies in order inside a single module is not so hard. Commands
can be chained by calling `next()` or `before()`. This will affect to commands
arrangement in the resulting Dockerfile.

## Command

A Dockerfile command is characterized with a following qualities:

* Combines - commands with the same keywords may be combined to one
* Overrides - a command with the same keyword will replace this command

A command, which does not combine nor it allows overriding, is a standalone
command. It may not be optimized and has to be added to the Dockerfile verbatim.
Combining commands requires some logic implemented and in the interim a command
may be standalone.

Standalone commands:

* `ADD`
* `COPY`

Combining commands:

* `RUN`
* `LABEL`
* `EXPOSE`
* `ENV`
* `VOLUME`

Overriding commands:

* `FROM`
* `MAINTAINER`
* `ENTRYPOINT`
* `USER`
* `WORKDIR`
* `CMD`

User has to be conscious about command overriding, i.e. to add a possibly overriding
command they must do it with `override()` function.

## Combinations

The engine will try to do its best to combine everything that can be combined.
Commands under the same keyword shall respect dependencies.

Example input (dependencies are commented):

```Dockerfile
RUN touch /etc/settings
RUN stat /etc/settings # the file must exist already
```

The output would be:

```Dockerfile
RUN touch /etc/settings && \
    stat /etc/settings
```

Dependencies with a different keyword will split combinations.

Example input:

```Dockerfile
RUN mkdir -p -m 0700 /etc/default
ADD settings /etc/default/ # Folder has to be created before a file is pushed
RUN stat /etc/default/settings
RUN touch /etc/other-settings
```

Results in:

```Dockerfile
RUN touch /etc/other-settings && \
    mkdir -p -m 0700 /etc/default
ADD settings /etc/default/
RUN stat /etc/default/settings
```
