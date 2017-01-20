class Skylab::Task

  class Eventpoint::Path_via_PendingExecutionPool_and_Graph < XXxxx

        # central thesis: start from the beginning node. at each current node
        # resolve exactly zero or one move that you can make. the ambiguity of
        # having multiple agents express a move (even the same one) triggers a
        # soft error and halts further execution. stop when either you reach
        # the target or you cannot make any more moves. if you did not reach
        # the goal (for any of the above reasons), you will have whined
        # appropritely and the result is false. else you were silent and
        # result is true-ish.
        # the above is a synopsis of the algorithm outlined in [#004].

    # ==
    # ==
  end
end
# :#tombstone-A: (could be temporary) remove legacy code (all) we are about to rewrite
