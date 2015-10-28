module Skylab::Brazen

  module Autonomous_Component_System

    module Mutation::Event_Factory_

      # (a placeholder for an idea)

      class << self

        def class_for sym

          _const = Callback_::Name.via_variegated_symbol( sym ).as_const
          const_get _const, false
        end
      end  # >>

      Entity_Already_Added = Callback_::Event.prototype_with(

        :entity_already_added,

        :entity, nil,
        :entity_collection, nil,

        :error_category, :key_error,
        :ok, false

      ) do | y, o |

        a = []
        subject = o.entity_collection.description_under self
        subject and a.push subject

        a.push 'already'

        conjugated_verb = 'has'  # (one day [#015])
        a.push conjugated_verb

        object = o.entity.description_under self
        object and a.push object

        y << ( a * SPACE_ )
      end

      Entity_Added = Callback_::Event.prototype_with(

        :entity_added,

        :entity, nil,
        :entity_collection, nil,

        :verb_symbol, :add,

        :ok, true

      ) do | y, o |

        _s = Home_.lib_.human::NLP::EN::POS::Verb[ o.verb_symbol.to_s ].preterite

        a = [ _s ]

        object = o.entity.description_under self
        if object
          a.push object
        end

        subject = o.entity_collection.description_under self
        if subject
          a.push 'to'
          a.push subject
        end

        y << ( a * SPACE_ )

        NIL_
      end

      def __WAS__verb_i
        @do_prepend ? :prepend : :append
      end

      Entity_Not_Found = Callback_::Event.prototype_with(

        :entity_not_found,

        :entity, nil,
        :entity_collection, nil,

        :error_category, :key_error,
        :ok, false

      ) do | y, o |

        a = []
        subject = o.entity_collection.description_under self
        subject and a.push subject

        a.push 'does not have'  # (one day [#015])

        object = o.entity.description_under self
        object and a.push object

        y << ( a * SPACE_ )
      end

      Entity_Removed = Callback_::Event.prototype_with(

        :entity_removed,

        :entity, nil,
        :entity_collection, nil,

        :is_completion, true,  # remember this? hehe
        :ok, true

      ) do | y, o |

        a = []

        a.push 'removed'  # (one day [#015])

        object = o.entity.description_under self
        object and a.push object

        subject = o.entity_collection.description_under self
        if subject
          a.push 'from', subject
        end

        y << ( a * SPACE_ )
      end
    end
  end
end
