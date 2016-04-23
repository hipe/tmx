module Skylab::Zerk

  class InteractiveCLI

  Buttonesque_Interpretation_Adapter_ = -> s, ada do

    oes_p = ada.UI_event_handler

    o = Begin_fuzzy_retrieve_[]

    # -- setup

    o.qualified_knownness = Callback_::Qualified_Knownness.
      via_value_and_symbol( s, :argument )  # ..
        # against this string

    o.stream_builder = -> do
      # of this stream of objects..

      ada.to_stream_for_resolving_buttonesque_selection
    end

    o.name_map = -> bsque do
      # use this string to compare it to the input ..

      bsque.hotstring_to_resolve_selection
    end

    o.be_case_sensitive = true  # we care about the difference

    # -- resultage

    o.success_map = -> bsque do
      bsque.load_ticket
    end

    o.on_event_selectively = -> * i_a, & ev_p do

      # because the outstream is oldchool, we've got to be *sure* that
      # the result from the callback here is false on error (nowadays
      # we treat it as `UNRELIABLE_`)

      x = oes_p[ * i_a, & ev_p ]

      if :error == i_a.first  # then result is
        :_unreliable_ == x or self._SANITY
        UNABLE_
      else
        self._INFO_from_button?
      end
    end

    _ = o.execute
    _
  end

  end
end
