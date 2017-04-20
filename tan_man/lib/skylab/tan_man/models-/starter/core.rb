module Skylab::TanMan

  module Models_::Starter

    # the "starter" "silo" and "graph" "silo" have this in common:
    #
    #   - both are represented in the config, and both are represented
    #     similarly. a single {graph|starter} is "selected", which means
    #     that some representation of a filesystem path is stored to the
    #     config, as a [#br-009] "assignment line".
    #
    #   - as such, both can be "unresolvable references", i.e. the config
    #     can have a path that does not have a referent on the filesystem.
    #     (e.g the file could have been remove since the assignment was made.)
    #
    # and then:
    #
    #   - starters (unlike graphs) can "splay", meaning we can list the
    #     available doo-hahs. (we could try to do this for graphs too
    #     with some kind of clever globbing etc but meh.)

    # (we were tempted to move the "item" class that is currently in the
    # "ls" action up to here, just to balance it out so this file isn't so
    # anemic but meh. also we were tempted to push the content that's in
    # this file upwards and have this just be a placeholder but also meh.)

    DESCRIPTION = -> y do

      self._NOTE  # NOTE: this const is not used for anything; it's just
      # an idea for how we could model a description for a pure branch node.
      # the "content" of the description below moved here from the [br]-era thing.

      y << "get or set the starter file used to create digraphs"
    end

    DEFAULT_STARTER_ = 'minimal.dot'

    # ==
    # ==
  end
end
# #history-A: broke out `list` and `get`
