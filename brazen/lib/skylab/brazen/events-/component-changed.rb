module Skylab::Brazen

  module Event_Support_  # :+"that trick"

    Events_::Component_Changed = Callback_::Event.prototype_with(  # :+[#035]:F

      :component_changed,

      :current_component, nil,
      :previous_component, nil,
      :component_association, nil,
      :ACS, nil,

      :ok, true,

    ) do | y, ev |
      o = ev.dup
      o.extend ev.class::Expresser___
      o.__express_into_under y, self
    end

    module Events_::Component_Changed::Expresser___

      include Expresser

      def __express_into_under y, expag

        initialize_as_expresser expag

        _verb_sym = :change  # :+[#035]:WISH-A
        _s = Home_.lib_.human::NLP::EN::POS::Verb[ _verb_sym.to_s ].preterite

        say _s

        if ! @did_express_context_chain_
          express_collection
        end

        say @component_association_string_

        say 'from'
        say_component @previous_component
        say 'to'
        say_component @current_component
        flush_into y
      end

      def index_component_related
        NIL_
      end
    end
  end
end
