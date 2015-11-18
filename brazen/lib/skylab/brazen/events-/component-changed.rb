module Skylab::Brazen

  module Event_Support_  # :+"that trick"

    expression = nil

    Events_::Component_Changed = Callback_::Event.prototype_with(  # :+[#035]:F

      :component_changed,

      :current_component, nil,
      :previous_component, nil,
      :context_as_linked_list_of_names, nil,
      :suggested_event_channel, nil,
      :verb_lemma_symbol, :change,

      :ok, true,

    ) do | y, ev |
      Express[ y, self, ev, & expression ]
    end

    expression = -> do

      express_verb_lemma_symbol_as_preterite

      express_context_as_linked_list_of_names

      accept_sentence_part 'from'
      express_component @previous_component
      accept_sentence_part 'to'
      express_component @current_component

      NIL_
    end
  end
end