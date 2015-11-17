module Skylab::Brazen

  module Event_Support_  # :+"that trick"

    Events_::Component_Removed = Callback_::Event.prototype_with(  # [#035]:B

      :component_removed,
      :component, nil,
      :component_association, nil,
      :ACS, nil,

      :is_completion, true,  # remember this? hehe
      :ok, true

    ) do | y, o |

      o = Event_Support_::Expresser[ self, o ]

      o << 'removed'  # one day [#035]:WISH-A
      o.express_component_via_members or accept_sentence_part 'component'
      o << 'from'
      o.express_collection_via_members or accept_sentence_part 'collection'
      o.flush_into y
    end
  end
end
