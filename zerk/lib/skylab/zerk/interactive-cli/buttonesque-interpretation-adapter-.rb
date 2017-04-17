module Skylab::Zerk

  class InteractiveCLI

  Buttonesque_Interpretation_Adapter_ = -> s, ada do

    oes_p = ada.UI_event_handler

    _qkn = Common_::QualifiedKnownness.via_value_and_symbol s, :argument  # ..

    _ = Home_.lib_.brazen::Magnetics::Item_via_OperatorBranch::FYZZY.call_by do |o|

      # -- setup

      o.qualified_knownness = _qkn  # needle

      o.item_stream_by do  # haystack

        ada.to_stream_for_resolving_buttonesque_selection
      end

      o.string_via_item_by do |buttonesque|

        # to compare a button to the input, derive a string from the button in this way

        buttonesque.hotstring_to_resolve_selection
      end

      o.levenshtein_number = LEVENSHTEIN_NUMBER_  # see

      o.will_be_case_sensitive  # we care about the difference

      # -- result & related

      o.result_via_found_by do |buttonesque|

        buttonesque.loadable_reference
      end

      o.listener = -> * i_a, & ev_p do

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
    end

    _  # hi.
  end

  end
end
