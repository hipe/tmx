module Skylab::Zerk

  class InteractiveCLI

  class Atomesque_Frame_  # (built in 1 place by event loop)

    # (watch for overlap with [#ac-003] the primitivesque for interface)
    # what belongs in here vs. in the view controller is some kind of thing

    def initialize bf, lt, el

      @below_frame = bf
      @event_loop = el
      @_line_yielder = el.line_yielder
      @loadable_reference = lt
      @_prompt_once = false  # nasty
      @UI_event_handler = el.UI_event_handler
    end

    # -- ..

    def begin_UI_panel_expression
      NIL_
    end

    def end_UI_panel_expression
      NIL_
    end

    # -- expression

    def button_frame

      if @_prompt_once
        @_prompt_once = false
        @_loadable_references_for_UI = nil
        NIL_

      else

        bx = @loadable_reference.association.transitive_capabilities_box
        if bx
          self._REVIEW
          @_loadable_references_for_UI = bx.a_.map do |sym|
            Common_::Name.via_variegated_symbol sym
          end

          Common_::Stream.via_nonsparse_array @_loadable_references_for_UI
        else

          @_loadable_references_for_UI = nil
          NIL_
        end
      end
    end

    def to_asset_reference_stream_for_UI
      Common_::Stream.via_nonsparse_array @_loadable_references_for_UI
    end

    # -- user input

    def process_mutable_string_input s  # contrast with sibling

      if @_loadable_references_for_UI  # will probably go away
        s.strip!
        if s.length.zero?
          @_line_yielder << "(nothing entered.)"
        else
          ___process_nonblank_string_as_button s
        end
      else
        Here_::Atomesque_Interpretation___.new( s, self ).execute
      end
      NIL_
    end

    def ___process_nonblank_string_as_button s

      nf = Here_::Buttonesque_Interpretation_Adapter_[ s, self ]
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

      self._README_needs_something_for_cold_model  # #cold-model

      # for user-defined single-symbol operations, all of them besides
      # `set` (ick) will be effected through a "normal" mutation session:

      a = [ sym ]
      a.push @loadable_reference.name_symbol

      _ACS = @event_loop.penultimate_frame.ACS

      _pp = self._SOMETHING

      ok = ACS_.edit a, _ACS, & _pp

      # this is subject to change, but for now, if the edit succeeds
      # we'll jump up a level..

      if ok
        @event_loop.pop_me_off_of_the_stack self
      end
      NIL_
    end

    def is_listy
      ( @___listy_kn ||= ___determine_listy_kn ).value_x
    end

    def ___determine_listy_kn
      Common_::Known_Known[ Is_listy_[ @loadable_reference.association.argument_arity ] ]
    end

    # -- events

    def interruption_handler  # c.p w/ [#045]
      -> do
        @event_loop.pop_me_off_of_the_stack self
        NIL_
      end
    end

    def model_emission_handler__
      @___oes_p ||= -> * i_a, & ev_p do
        receive_uncategorized_emission i_a, & ev_p
      end
    end

    def receive_uncategorized_emission i_a, & ev_p

      @event_loop.receive_uncategorized_emission i_a, & ev_p
      UNRELIABLE_
    end

    # -- instrinsic constituency & shape reflection

    def name
      @loadable_reference.name
    end

    attr_reader(
      :below_frame,
      :event_loop,
      :loadable_reference,
    )

    def four_category_symbol
      :primitivesque
    end
  end

  end
end
