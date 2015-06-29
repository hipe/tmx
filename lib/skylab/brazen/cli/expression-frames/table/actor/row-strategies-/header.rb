module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Row_Strategies_::Header

      ARGUMENTS = [
        :argument_arity, :one, :property, :header,
      ]

      ROLES = nil

      SUBSCRIPTIONS = [
        :argument_bid_for,
        :receive_complete_field_list,
      ]

      Table_Impl_::Strategy_::Has_arguments[ self ]

      def initialize x
        @parent = x
        @_yes_header = true
      end

      def dup x
        otr = self.class.new x
        otr.__init_dup @_yes_header
        otr
      end

      def __init_dup yes
        @_yes_header = yes
        NIL_
      end

      def receive__header__argument none

        if :none == none
          @_yes_header = false
          KEEP_PARSING_
        else
          raise ::ArgumentError, __say_kw( none )
        end
      end

      def __say_kw x

        "keyword 'none' is mandatory here #{
          }(had #{ Home_.lib_.basic::String.via_mixed x })"
      end

      def receive_complete_field_list fld_a

        if fld_a && fld_a.length.nonzero?
          @_fld_a = fld_a
          @parent.receive_subscription self, :before_first_row
        end
        NIL_
      end

      def before_first_row

        if @_yes_header
          __express_header_row
        end
      end

      def __express_header_row

        @parent.begin_argument_row
        @_fld_a.each_with_index do | fld, d |
          s = fld.label
          if s
            @parent.receive_celifier_argument s, d
          else
            @parent.receive_celifier_argument EMPTY_S_, d
          end
        end
        @parent.finish_argument_row
        NIL_
      end
    end
  end
end
