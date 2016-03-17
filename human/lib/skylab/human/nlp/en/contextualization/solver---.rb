module Skylab::Human

  class NLP::EN::Contextualization

    class Solver___ < ::Class.new

      #   • resolve a target node given a graph
      #   • VERY experimental and VERY fun
      #   • has many known holes (see comments throughout)
      #   • is a prototype for "magnetics"

      class << self
        def new_for__ nodes
          new.__init_for nodes
        end
        private :new
      end  # >>

      def initialize
        # (override parent)
      end

      def __init_for nodes
        @_entry_via_destination = ::Hash[ nodes.map { |i| [ i, nil ] } ]
        @_entries = []
        self
      end

      # -- when editing ..

      def add_entry__ when_x, can_produce_x, & by_p

        d = @_entries.length
        entry = Entry___.new d, when_x, can_produce_x, & by_p
        @_entries[d] = entry

        entry._can_produce_sym_a.each do |sym|
          a = @_entry_via_destination.fetch sym
          if ! a
            a = []
            @_entry_via_destination[ sym ] = a
          end
          a.push d
        end

        NIL_
      end

      # -- when done editing..

      def to_read_only__

        @___read_only ||= Read_Only___.new @_entry_via_destination, @_entries
      end

      def is_writable_
        true
      end

      Read_Only___ = superclass
      class Read_Only___

        # fun - every "solver" has zero or one "read only" sidecar.
        # the read-only is like a solver but the read-only cannot mutate
        # the data it draws from.

        # amazingly (and dangerously) both the solver and its the read-only
        # sidecar hold references (as ivars) to *the same* (relevant) index-
        # related objects. this way, after the read-only "splits" off the
        # solver, if the solver makes any subsequent edits, the read-only
        # (s) will reflect these changes.
        #
        # the way we implement this is fun to us: the read-only class is
        # actually the superclass of the solver class. all of the read-
        # related methods go in the superclass and all of the write-related
        # ones go in the sub-class.

        def initialize h, a
          @_entry_via_destination = h ; @_entries = a
        end

        def bound_to_knowns__ kns
          Bound_Read_Only___.new kns, @_entry_via_destination, @_entries
        end

        def is_writable_
          false
        end
      end

      class Bound_Read_Only___

        def initialize o, h, a
          @_entries = a
          @_entry_via_destination = h
          @knowns_ = o
        end

        def __explain stack
          _prefix = if 1 == stack.length
            "from the starting state "
          else
            "under (#{ stack[ 0..-2 ] * ', ' }) "
          end
          "#{ _prefix }'#{ stack.last }' was necessary but was not set"
        end

        def solve_for_ k

          x = _read_knownness_for k
          if x
            x
          else
            Solve__.new( [k], {}, self ).execute
          end
        end

        def _read_knownness_for k
          @knowns_.send k
        end

        attr_reader(
          :_entries,
          :_entry_via_destination,
          :knowns_,
        )
      end

      class Solve__

        # presently we're implementing this to be "myopic" and
        # "deterministic" - by "myopic" we mean that this asserts that
        # there is only one edge that can be traversed to solve each node.
        # by "deterministic" we mean that it asserts that there *is*
        # one edge to solve at each node.
        #
        # this is purely for ease-of-implementation while prototyping this,
        # and can be improved upon later.

        def initialize stack, seen, rdr
          @_reader = rdr
          @knowns_ = rdr.knowns_
          @_seen = seen
          @_stack = stack
        end

        def execute  # assume not seen and not known

          k = @_stack.last
          @_seen[ k ] = true
          _recurse
          _ = @knowns_.send k
          _
        end

        def _recurse

          ways = @_reader._entry_via_destination.fetch @_stack.last

          if ! ways
            # for now we are "deterministic"
            raise ::KeyError, @_reader.__explain( @_stack )
          end

          if 1 != ways.length
            self._COVER_ME_many_solutions  # for now we are "myopic"
          end

          entry = @_reader._entries.fetch ways.fetch 0

          # for this "entry", solve for each of its inputs..

          entry._when_sym_a.each do |k|

            x = @_reader._read_knownness_for k
            x and next

            stack = [ * @_stack, k ]

            _did = @_seen.fetch k do
              @_seen[ k ] = true ; false
            end
            if _did
              self._COVER_ME_circular_dependency  # and see #[#ta-007]
            end

            _new_brosef = Solve__.new stack, @_seen, @_reader

            _new_brosef._recurse
          end

          entry._by_p.call @knowns_

          NIL_
        end
      end

      class Entry___

        def initialize d, when_x, can_produce_x, & by_p
          @_entry_id = d
          @_when_sym_a = Array_convert__[ when_x ]
          @_can_produce_sym_a = Array_convert__[ can_produce_x ]
          @_by_p = by_p
        end

        attr_reader(
          :_entry_id,
          :_when_sym_a,
          :_can_produce_sym_a,
          :_by_p,
        )
      end

      Array_convert__ = -> x do
        ::Array.try_convert( x ) || [ x ]
      end
    end
  end
end
