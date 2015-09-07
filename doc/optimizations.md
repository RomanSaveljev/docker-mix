Every module adds its commands to the generated Dockerfile. There are certain
heuristics we may implement to save on layers and make the process easier to
understand.

## FROM is the first command

`FROM` is always the first command in a valid Dockerfile. There may be only one
`FROM` command per Dockerfile. All other commands will directly or indirectly
depend on it, so it will always be at the top of the tree.

## Commands natural order

User will likely want to see the commands in the order they are added by the code.
Commands added by a module need to be kept together.

## USER command is at the end

`USER` command changes the execution context irreversibly. If used, it must be
kept at the end of the output. It may not depend on other commands, but others
may depend on it.

## Best effort 'do after'

When `doAfter()` link is created, it means every effort has to be made to put
the dependency right before the dependent. Dependencies should not be combined.
