module Skylab::Zerk

  class Primitivesque_Adapter___  # :[#003].

    # (watch for overlap with [#ac-003] the primitivesque for interface)

    def initialize qkn, rsx

      @_line_yielder = rsx.line_yielder
      @_qkn = qkn
      @_rsx = rsx
      @_view_controller = rsx.view_controller

      @_EEK = false
    end

    # -- expression

    def any_button_name_stream

      if @_EEK
        @_EEK = false
        @last_buttonesques_ = nil
        NIL_

      elsif @_qkn.association.has_operations

        _bx = @_qkn.association.operations_box_read_only

        @last_buttonesques_ = _bx.a_.map do | sym |
          Callback_::Name.via_variegated_symbol sym
        end

        Callback_::Stream.via_nonsparse_array @last_buttonesques_
      else

        @last_buttonesques_ = nil
        NIL_
      end
    end

    attr_reader :last_buttonesques_

    def express_prompt  # in lieu of above

      @_rsx.serr.write "enter #{ @_qkn.name.as_slug }: "
      NIL_
    end

    # -- user input

    def process_mutable_string_input s  # contrast with sibling

      if @last_buttonesques_
        s.strip!
        if s.length.zero?
          @_line_yielder << "(nothing entered.)"
        else
          ___process_nonblank_string_as_button s
        end
      else
        s.chomp!
        __process_string_as_value s
      end
      NIL_
    end

    def ___process_nonblank_string_as_button s

      nf = Interpret_buttonesque_[ s, self ]
      if nf
        sym = nf.as_variegated_symbol
        if :set == sym  # #NASTY
          @_EEK = true
        else
          ___do_this_via_edit sym
        end
      end
      NIL_
    end

    def ___do_this_via_edit sym

      # for user-defined single-symbol operations, all of them besides
      # `set` (ick) will be effected through a "normal" mutation session:

      a = [ sym ]
      a.push @_qkn.name.as_variegated_symbol

      _ACS = @_view_controller.stack_penultimate.ACS  # #NASTY

      ok = ACS_.edit a, _ACS  # we could pass some arbitrary (oes_p_p)
      # handler here, but instead we (for now) defer eventing to the
      # argument ACS because they seem to be all internally wired.
      # :[#]detail-one

      # this is subject to change, but for now, if the edit succeeds
      # we'll jump up a level..

      if ok
        @_view_controller.pop_me_off_of_the_stack self
      end
      NIL_
    end

    def __process_string_as_value s

      # we don't care what the old value was or whether there was one.
      # we don't need no stinking API .. it's primitivesque. just call it..

      _st = ACS_::Interpretation::Value_Popper[ s ]

      wv = @_qkn.association.component_model.call _st, & _handler_maker
      if wv
        ___assign_value wv
      end
      NIL_
    end

    def ___assign_value wv

      # but wait: we do care..

      _ACS = @_view_controller.stack_penultimate.ACS  # #NASTY

      p = ACS_::Interpretation::Accept_component_change[
        wv.value_x,
        @_qkn,
        _ACS,
      ]

      _handler.call :info, :set_leaf_component do
        p[]
      end

      @_view_controller.pop_me_off_of_the_stack self

      NIL_
    end

    # -- events

    def handler_for sym, *_
      if :interrupt == sym
        -> do
          @_view_controller.pop_me_off_of_the_stack self
          NIL_
        end
      end
    end

    def _handler_maker
      -> _ do
        _handler
      end
    end

    def _handler
      @___oes_p ||= -> * i_a, & ev_p do
        receive_uncategorized_emission i_a, & ev_p
      end
    end

    def receive_uncategorized_emission i_a, & ev_p

      @_view_controller.receive_uncategorized_emission i_a, & ev_p
      UNRELIABLE_
    end

    # -- instrinsic shape reflection

    def is_branchesque_
      false
    end
  end
end
