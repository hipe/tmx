class Skylab::Task

  module Magnetics

    class Magnetics_::ItemTicket_via_TokenStream < Common_::Actor::Monadic

      # [#011] explains what the heck this is, why the heck we aren't
      # using plain old regex, and how the heck you are supposed to develop
      # this way. it is a MUST READ if you're reading this.

      def initialize st, & oes_p
        @on_event_selectively = oes_p
        @token_stream = st
      end

      def execute

        # (yay our whole parsing algorithm is confined to this one main loop)

        @_ok = true
        _move_to_state :BT20
        st = remove_instance_variable :@token_stream
        begin
          @_word = st.gets
          if @_word
            sym = TOKEN_CATEGORY__[ @_word ]
            m = @_transistions[ sym ]
            if m
              send m
              @_ok ? redo : break
            end
            @_ok = _when_no_transition sym
            break
          end
          @_ok = st.ok
          break
        end while nil

        if @_ok
          m = @_transistions[ :end ]
          if m
            send m
          else
            _when_no_transition :end
          end
        else
          @_ok
        end
      end

      h = {
        "and" => :and,
        "as" => :as,
        "via" => :via,
      }
      h.default_proc = -> _h, _k do
        :other
      end
      TOKEN_CATEGORY__ = h

      FSA__ = {}

      # -- area 20

      FSA__[ :BT20 ] = {
        other: :__transition_from_BT20_to_IT20,
      }

      FSA__[ :IT20 ] = {
        end: :__transition_from_IT20_to_finish20,
        as: :__transition_from_IT20_to_BT40,
        and: :__transition_from_IT20_to_BT60,
        via: :__transition_from_IT20_to_BT80,
        other: :__transition_from_IT20_to_IT20,
      }

      def __transition_from_BT20_to_IT20
        _begin_term
        _move_to_state :IT20
      end

      def __transition_from_IT20_to_IT20
        _add_word_to_term
      end

      def __transition_from_IT20_to_BT40
        @__slot_term_symbol = _finish_term
        _move_to_state :BT40
      end

      def __transition_from_IT20_to_BT60
        @_function_product_term_list = [ _finish_term ]
        _move_to_state :BT60
      end

      def __transition_from_IT20_to_BT80
        @_function_product_term_list = [ _finish_term ]
        @_function_precondition_term_list = []
        _move_to_state :BT80
      end

      def __transition_from_IT20_to_finish20
        Here_::Models_::Unassociated_ItemTicket.new _finish_term
      end

      # -- area 40

      FSA__[ :BT40 ] = {
        other: :__transition_from_BT40_to_IT40,
      }

      FSA__[ :IT40 ] = {
        other: :__transition_from_IT40_to_IT40,
        end: :__transition_from_IT40_to_finish40,
      }

      def __transition_from_BT40_to_IT40
        _begin_term
        _move_to_state :IT40
      end

      def __transition_from_IT40_to_IT40
        _add_word_to_term
      end

      def __transition_from_IT40_to_finish40

        Here_::Models_::Manner_ItemTicket.new(
          _finish_term,
          @__slot_term_symbol,
        )
      end

      # -- area 60

      FSA__[ :BT60 ] = {
        other: :__transition_from_BT60_to_IT60,
      }

      FSA__[ :IT60 ] = {
        other: :__transition_from_IT60_to_IT60,
        and: :__transition_from_IT60_to_BT60,
        via: :__transition_from_IT60_to_BT80,
      }

      def __transition_from_BT60_to_IT60
        _begin_term
        _move_to_state :IT60
      end

      def __transition_from_IT60_to_IT60
        _add_word_to_term
      end

      def __transition_from_IT60_to_BT60
        @_function_product_term_list.push _finish_term
        _move_to_state :BT60
      end

      def __transition_from_IT60_to_BT80
        @_function_product_term_list.push _finish_term
        @_function_precondition_term_list = []
        _move_to_state :BT80
      end

      # -- area 80

      FSA__[ :BT80 ] = {
        other: :__transition_from_BT80_to_IT80,
      }

      FSA__[ :IT80 ] = {
        and: :__transition_from_IT80_to_BT80,
        end: :__transition_from_IT80_to_finish80,
        other: :__transition_from_IT80_to_IT80,
      }

      def __transition_from_BT80_to_IT80
        _begin_term
        _move_to_state :IT80
      end

      def __transition_from_IT80_to_IT80
        _add_word_to_term
      end

      def __transition_from_IT80_to_BT80
        @_function_precondition_term_list.push _finish_term
        _move_to_state :BT80
      end

      def __transition_from_IT80_to_finish80

        @_function_precondition_term_list.push _finish_term

        Here_::Models_::Function_ItemTicket.via_prerequisites_and_products__(
          @_function_precondition_term_list,
          @_function_product_term_list,
        )
      end

      # -- area N

      # --

      def _begin_term
        @_term_in_progress = remove_instance_variable :@_word ; nil  # WILL MUTATE TOKEN (for now (ick))
      end

      def _add_word_to_term
        @_term_in_progress << UNDERSCORE_
        @_term_in_progress << ( remove_instance_variable :@_word )
      end

      def _finish_term
        remove_instance_variable( :@_term_in_progress ).intern
      end

      def _move_to_state sym
        @_state = sym
        @_transistions = FSA__.fetch sym
        NIL_
      end

      def _when_no_transition sym

        o = Here_::Models_::ItemSyntaxExplanation.begin

        o.word = @_word
        o.unexpected_token_category = sym

        o.state = @_state
        o.FSA = FSA__
        o.token_category_symbols = TOKEN_CATEGORY__.values

        o = o.finish

        oes_p = @on_event_selectively

        if oes_p
          oes_p.call( * o.get_channel ) do
            o
          end
          UNABLE_
        else
          raise o.to_exception
        end
      end
    end
  end
end
