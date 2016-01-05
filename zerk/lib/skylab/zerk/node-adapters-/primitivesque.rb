module Skylab::Zerk

  class Node_Adapters_::Primitivesque  # :[#003]. (built in 1 place by event loop)

    # (watch for overlap with [#ac-003] the primitivesque for interface)
    # what belongs in here vs. in the view controller is some kind of thing

    def initialize qkn, rsx

      @_line_yielder = rsx.line_yielder
      @_qkn = qkn
      @UI_event_handler = rsx.UI_event_handler
      @view_controller = rsx.view_controller

      @_prompt_once = false  # nasty
    end

    # -- ..

    def begin_UI_frame
      NIL_
    end

    def end_UI_frame
      NIL_
    end

    # -- expression

    def button_frame

      if @_prompt_once
        @_prompt_once = false
        @_UI_frame_nodes = nil
        NIL_

      elsif @_qkn.association.has_operations

        _bx = @_qkn.association.operations_box_read_only

        @_UI_frame_nodes = _bx.a_.map do | sym |
          Callback_::Name.via_variegated_symbol sym
        end

        Callback_::Stream.via_nonsparse_array @_UI_frame_nodes
      else

        @_UI_frame_nodes = nil
        NIL_
      end
    end

    def to_UI_frame_item_stream

      Callback_::Stream.via_nonsparse_array @_UI_frame_nodes
    end

    # -- user input

    def process_mutable_string_input s  # contrast with sibling

      if @_UI_frame_nodes
        s.strip!
        if s.length.zero?
          @_line_yielder << "(nothing entered.)"
        else
          ___process_nonblank_string_as_button s
        end
      else

        s.chomp!  # remove trailing newline entered that initiates a `gets`,
        # but we leave any leading space intact for downstream to decide on.

        __process_string_as_value s
      end
      NIL_
    end

    def ___process_nonblank_string_as_button s

      nf = Home_::Interpretation_Adapters_::Buttonesque[ s, self ]
      if nf
        sym = nf.as_variegated_symbol
        if :set == sym  # #NASTY
          @_prompt_once = true
        else
          ___do_this_via_edit sym
        end
      end
      NIL_
    end

    attr_reader(
      :UI_event_handler,  # for buttonesque
    )

    def ___do_this_via_edit sym

      # for user-defined single-symbol operations, all of them besides
      # `set` (ick) will be effected through a "normal" mutation session:

      a = [ sym ]
      a.push @_qkn.name.as_variegated_symbol

      _ACS = @view_controller.stack_penultimate.ACS  # #NASTY

      ok = ACS_.edit a, _ACS  # we could pass some arbitrary (oes_p_p)
      # handler here, but instead we (for now) defer eventing to the
      # argument ACS because they seem to be all internally wired.
      # :#thread-one

      # this is subject to change, but for now, if the edit succeeds
      # we'll jump up a level..

      if ok
        @view_controller.pop_me_off_of_the_stack self
      end
      NIL_
    end

    def __process_string_as_value s

      # for now we don't care if there was one and if so what the old value
      # was; but if you did, that processing would happen here.
      # what we *do* care about is if this is a dootily, then we footily.

      if is_listy
        a = Home_::Interpretation_Adapters_::List[ s, & @UI_event_handler ]
        if a
          st = ACS_::Interpretation::Value_Popper[ a ]
        end  # else emitted
      else
        st = ACS_::Interpretation::Value_Popper[ s ]
      end

      if st
        wv = @_qkn.association.component_model.call st, & _handler_maker
        if wv
          ___assign_value wv
        end
      end
      NIL_
    end

    def is_listy
      Is_listy_[ @_qkn.association.argument_arity ]
    end

    def ___assign_value wv

      # but wait: we do care..

      _ACS = @view_controller.stack_penultimate.ACS  # #NASTY

      p = ACS_::Interpretation::Accept_component_change[
        wv.value_x,
        @_qkn,
        _ACS,
      ]

      _handler.call :info, :set_leaf_component do
        p[]
      end

      @view_controller.pop_me_off_of_the_stack self

      NIL_
    end

    # -- events

    def handler_for sym, *_
      if :interrupt == sym
        -> do
          @view_controller.pop_me_off_of_the_stack self
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

      @view_controller.receive_uncategorized_emission i_a, & ev_p
      UNRELIABLE_
    end

    # -- instrinsic constituency & shape reflection

    def name
      @_qkn.name
    end

    def shape_symbol
      :primitivesque
    end
  end
end
