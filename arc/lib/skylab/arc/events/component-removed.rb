module Skylab::Arc

  module Event_Support_  # #[#sl-155] scope stack trick

    Events::ComponentRemoved = Common_::Event.prototype_with(  # :[#007.2]

      :component_removed,
      :component, nil,
      :component_association, nil,
      :ACS, nil,

      :is_completion, true,  # remember this? hehe
      :ok, true

    ) do | y, o |

      o = Event_Support_::ExpressionMethods[ self, o ]

      o << 'removed'  # one day #wish #[#007.G]
      o.express_component_via_members or accept_sentence_part 'component'
      o << 'from'
      o.express_collection_via_members or accept_sentence_part 'collection'
      o.flush_into y
    end
  end
end
