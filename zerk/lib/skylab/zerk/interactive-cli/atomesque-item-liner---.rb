module Skylab::Zerk

  class InteractiveCLI

    class Atomesque_Item_Liner___ < Common_::Dyadic  # references reference [#038]

      def initialize lt, _

        _.expression_agent  # LOOK
        _.compound_frame  # LOOK

        @loadable_reference = lt
      end

      def execute

        @_qk = @loadable_reference.to_qualified_knownness__

        _is_listy = Is_listy_[ @_qk.association.argument_arity ]
        _is_known = @_qk.is_effectively_known

        if _is_listy
          if _is_known
            __when_known_list
          else
            __when_unknown_list
          end
        elsif _is_known
          __when_known_atom
        else
          __when_unknown_atom
        end
      end

      def __when_unknown_list
        NONE__
      end

      def __when_known_list

        # now, an entity-item table *is* a two-dimensional thing, but nah..

        _x_a = @_qk.value

        long_s = ""
        y = Basic_[]::Yielder::Mapper.joiner( long_s, ', ' ).y

        _prepare_etc

        _x_a.each do |x|

          s = @_string_via_mixed[ x ]
          s or self._COVER_ME
          y << s
        end

        [ long_s ]
      end

      def __when_unknown_atom
        NONE__
      end

      NONE__ = [ '(none)' ]

      def __when_known_atom

        _prepare_etc

        _ = @_string_via_mixed[ @_qk.value ]

        [ _ ]
      end

      def _prepare_etc

        _QUOTEWORTHY_RX = /[[:space:]'",]/

        o = Basic_[]::String.via_mixed.dup

        o.non_long_string_by = -> s do

          if _QUOTEWORTHY_RX =~ s
            s.inspect
          else
            s
          end
        end

        @_string_via_mixed = o.to_proc
        NIL_
      end

      # ==
    end
  end
end
# #history: outgrew "compound frame view controller"
