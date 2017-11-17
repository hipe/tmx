class Skylab::Task

  class Magnetics_::Plan_via_Index < Common_::MagneticBySimpleModel

    # we're calling this the third known implementation of [#005] pathfinding.

    # building a plan (in our linear, synchronous fashion such as things
    # are) involves arranging the nodes in a (sometimes partially
    # arbitrary) sequence such when we arrive at each node, it is
    # guaranteed to have all its dependencies met.
    #
    # (this algorithm is not concerned with whether the nodes themselves
    # will complete their particular tasks; for the sake of the algorithm,
    # imagine that they all do.)
    #
    # it is assumed that if the graph succeeded in being indexed, that
    # it does not cycle. furthermore it is assumed that there must be
    # at least one node with no dependees. ergo it is assumed that the
    # graph has at least one node.
    #
    # for each node with no dependees, "erase" this node from the graph
    # where erasing means:
    #
    #   • adding this erased node to the sequence.
    #
    #   • removing the arcs that pointed to this node.
    #
    # it is assumed that having erased arcs from the graph in this manner
    # *must* yield more nodes with no dependees (but we have not proven
    # this.) repeat this process until there are no more nodes in the
    # graph.

    def listener= p
      @_listener = p
    end

    attr_writer(
      :index
    )

    def execute

      outie = @index.box_of_dependees_via_depender.h_
      innie = @index.dependers_via_dependee

      subscribers = {}
      innie.each_pair do | k, a |
        subscribers[ k ] = a.dup
      end

      sequence = []
      memo_stack = []

      nothing_stack = innie.fetch :_NOTHING_

      begin

        # for each node (symbol) that is known to depend on nothing,
        # clear that array of these symbols while memoing them.

        terminal = nothing_stack.pop
        terminal or self._SANITY
        begin
          memo_stack.push terminal
          terminal = nothing_stack.pop
        end while terminal

        sequence.concat memo_stack
        if 1 == innie.length  # the _NOTHING_ item egads
          break
        end

        # for that same list again, for each item, remove its entry
        # from the "innie" hash, which itself produces a list. for
        # each item of *this* list, remove *its* arcs appropriately,
        # noting when this process leads to newly terminal nodes.

        while terminal = memo_stack.pop

          outie.delete terminal  # remove the empty array
          a = innie.delete terminal  # remove the non-empty array of..

          while k = a.pop

            a_ = outie.fetch k
            _d = a_.index terminal
            a_[ _d, 1 ] = EMPTY_A_

            if a_.length.zero?

              nothing_stack.push k
            end
          end
        end

        redo
      end while nil

      Plan___.new(
        sequence,
        subscribers,
        @index.cache_box.h_ )
    end

    Plan___ = ::Struct.new :queue, :subscribers, :cache
  end
end
