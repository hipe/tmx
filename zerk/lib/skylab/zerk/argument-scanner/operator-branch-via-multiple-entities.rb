module Skylab::Zerk

  module ArgumentScanner

    class OperatorBranch_via_MultipleEntities  # :[#051.E].

      # NOTE :#open: this needs to be de-duped with the new work
      # in "no-deps" near its own feature injection. ideally this node
      # would just go away in lieu of that..

      # #[#051] :[#053] - this is currently *the* center of implementation
      # for "feature injection". (theory at document.)
      #
      # is an operator branch that is an aggregation of N different other
      # operator branches. each branch that goes into the definition of the
      # subject must be associated with a "value store".
      #
      # the subject exposes special method for parsing, outside of the API
      # of normal operator branches (discussed below). this parsing will
      # dispatch each "at" occurrence to the appropriate value store to
      # further process that portion of the argument stream head it is
      # interested in.
      #
      # (typically the value stores are operations, but really they could
      # be anything that responds to `at_from_syntaxish`.).
      #
      #
      #
      #
      # ## about our "mutability model" :#note-2
      #
      # most adaptations of operator branches seem to adhere to a
      # "mutability model" whereby they themselves are immutable (or could
      # be) and also their member objects are immutable too, recursively.
      #
      # this mutability model makes these adaptations amenable to the
      # "dup-and-mutate" pattern; and more generally is a byproduct of
      # their simplicity, which in turn is a nod to the [#sl-129]
      # "single responsibilty principle".
      #
      # the subject, however, holds *as* its member data the very
      # value stores that its parses are to write into. to attempt to do
      # othewise would make for a substantially more complex interface.
      #
      # the main uptake of this is that the subject is distinct among
      # its sibling adaptations in that it can expose a method that parses
      # that needs only one argument: the argument stream (because the
      # subject already has the value stores as members).
      #
      #
      #
      #
      # # #note-1 is about what happens with hash collisions between
      # branches.
      #
      # (#a.s-coverpoint-1)

      class << self
        alias_method :define, :new
        undef_method :new
      end  # >>

      # -

        def initialize
          @_count = 0
          @_operator_braches = []
          @_value_stores = []
          yield self
        end

        # -- define time

        def add_entity_and_operator_branch vs, ob
          d = @_count
          @_count += 1
          @_operator_braches[d] = ob
          @_value_stores[d] = vs
          NIL
        end

        # -- read-time

        def parse_all_from argument_scanner

          # (normally you wouldn't expose a method like this, but for #note-2)

          _ = Here_::Syntaxish.via_operator_branch self

          _ok = _.parse_all_into_from(
            DISPATCHING_VALUE_RECEIVER___, argument_scanner )

          _ok  # #todo
        end

        def emit_idea_by
          NOTHING_
        end

        def lookup_softly k  # #[#ze-051.1] "trueish item value"
          my_trueish_x = nil
          @_count.times do |d|
            trueish_x = @_operator_braches[d].lookup_softly k
            trueish_x || next
            my_trueish_x = _special_value @_value_stores.fetch(d), trueish_x
            break
          end
          my_trueish_x
        end

        def to_pair_stream

          # for help screen, for fuzzy lookup.
          #
          # produce a stream that will produce one item per associative
          # entry given at definition time. each such item will be another
          # stream whose items are the pairs. finally, flatten this first
          # stream so that the end result is a stream of the pairs.

          Common_::Stream.via_times @_count do |d|

            ob = @_operator_braches.fetch d

            vs = @_value_stores.fetch d

            p = ob.method :dereference

            ob.to_loadable_reference_stream.map_by do |k|

              Common_::Pair.via_value_and_name( _special_value( vs, p[k] ), k )
            end

          end.expand_by do |st|

            st  # (this is how you flatten a stream of streams into a stream of items)
          end
        end

        def to_loadable_reference_stream

          Common_::Stream.via_times @_count do |d|
            @_operator_braches.fetch d
          end.expand_by do |ob|
            ob.to_loadable_reference_stream
          end
        end

        def _special_value x, xx
          ValueStoreAndUserValue___.new x, xx
        end
      # -

      # ==

      module DISPATCHING_VALUE_RECEIVER___ ; class << self

        # because we store the target value store *in* the routing struct,
        # the receiver of this method call can be both stateless AND
        # memberless, so a singleton like this.

        def at_from_syntaxish o

          routing = o.branch_item_value

          _value_store = routing.value_store

          _user_x = routing.mixed_user_value

          _item_again = Here_::OperatorBranchItem.
            via_user_value_and_normal_symbol(
              _user_x, o.branch_item_normal_symbol )

          _value_store.at_from_syntaxish _item_again
        end
      end ; end

      # ==

      ValueStoreAndUserValue___ = ::Struct.new :value_store, :mixed_user_value
        # (the above members are public API ([tmx]))

      # ==
    end
  end
end
# #history: "compounded primaries" reconceived as operator branch
