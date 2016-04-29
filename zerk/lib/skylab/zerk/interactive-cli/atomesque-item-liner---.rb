module Skylab::Zerk

  class InteractiveCLI

    class Atomesque_Item_Liner___ < Callback_::Actor::Dyadic  # references reference [#038]

      def initialize lt, _

        _.expression_agent  # LOOK
        _.compound_frame  # LOOK

        @load_ticket = lt
      end

      def execute

        @_qk = @load_ticket.to_qualified_knownness__

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
        self._COVER_ME_and_design_me
      end

      def __when_known_list
        self._LOOK_AT_NOTES
      end

      def __when_unknown_atom
        NONE___
      end

      NONE___ = [ '(none)' ]

      def __when_known_atom

        __prepare_dootily_hah

        _ = @_string_via_mixed[ @_qk.value_x ]

        [ _ ]
      end

      def __prepare_dootily_hah

        _QUOTEWORTHY_RX = /[[:space:]'",]/

        o = Home_.lib_.basic::String.via_mixed.dup

        o.on_nonlong_stringish = -> s, _ do

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
