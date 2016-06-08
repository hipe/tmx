module Skylab::Brazen

  class Branchesque::Indexation

    class Unbound_Via___ < ::BasicObject

      # experiment #open [#067] support different selection shapes
      # for nodes in the reactive model tree

      def initialize idx
        @_indexation = idx
      end

      def const sym, & x_p

        # lookup an unbound by a const *symbol* (not string)

        normal_identifier [ sym ], & x_p
      end

      def normal_identifier const_a, & x_p

        # lookup an unbound by a "normal identifier" where a normal
        # identifier is an array of consts representing a path from the
        # treetop to the target node *taking into account promotion*

        __normal_stream(
          Common_::Polymorphic_Stream.via_array( const_a ),
          & x_p )
      end

      def __normal_stream st, & x_p

        const = st.gets_one
        x = @_indexation.any_unbound_via_const const
        if x
          if st.unparsed_exists
            self._COVER_ME
            x.__WOULD_BE__unbound_via_normal_stream st, & x_p
          else
            x
          end
        else
          self._COVER_ME
        end
      end
    end
  end
end
