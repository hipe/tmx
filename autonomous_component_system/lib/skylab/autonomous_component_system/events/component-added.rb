module Skylab::Autonomous_Component_System

  module Event_Support_  # [#sl-155] scope stack trick

    expression = nil

    Events::ComponentAdded = Common_::Event.prototype_with(  # :[#007.4]

      :component_added,

      :component, nil,
      :context_as_linked_list_of_names, nil,
      :suggested_event_channel, nil,
      :verb_lemma_symbol, :add,
      :context_expresses_slot, false,

      :ok, true,

    ) do | y, ev |
      Express[ y, self, ev, & expression ]
    end

    expression = -> do

      # we use the term "added" loosely - experimentally we also use this
      # same event for when we put a component in a "slot" (that can only
      # hold one component), which we typically use the verb "set" for.
      #
      # you could "set 'tempurature' to '30'". "tempurature" is the name
      # for the 'association' which would get passed to this event in the
      # context linked list.
      #
      # but this event was originally created for expressing that a component
      # ("element") was added to a collection. for those uses the name
      # function(s) describing the collection is what context is for.
      #
      # when the context expresses the association, it comes first:
      #
      #     "set 'color' to 'blue'"
      #
      # but when context is collection, order is reversed EEK!
      #
      #     "added 'money' to 'pocket'"

      express_verb_lemma_symbol_as_preterite

      _is = @context_expresses_slot

      if _is
        express_context_as_linked_list_of_names
      else
        express_component @component
      end

      accept_sentence_part 'to'

      if _is
        express_component @component
      else
        express_context_as_linked_list_of_names
      end

      NIL_
    end
  end
end
