module Skylab::Brazen

  # the purpose of this file is exactly twofold. it is:
  #
  #   1) to define the eponymous module (because it must)
  #
  #   2) to define a support module that many client event modules
  #      will pull in using 'the trick'
  #
  # (but while we are at it we stowaway "small" event prototypes here too)

  Autoloader_[ Events_ = ::Module.new ]

  module Events_
    # ->

      Entity_Already_Added = Callback_::Event.prototype_with(  # :+[#035]:C

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

      Entity_Added = Callback_::Event.prototype_with(  # :+[#035]:D

        :entity_added,

        :entity, nil,
        :entity_collection, nil,

        :verb_symbol, :add,

        :ok, true

      ) do | y, o |

        _s = Home_.lib_.human::NLP::EN::POS::Verb[ o.verb_symbol.to_s ].preterite

        a = [ _s ]

        s = o.entity.description_under self
        if s
          a.push s
        end

        acs = o.entity_collection
        s = acs.description_under self
        if ! s
          s = acs.name.as_human
        end
        a.push 'to'
        a.push s

        y << ( a * SPACE_ )

        NIL_
      end

      def __WAS__verb_i
        @do_prepend ? :prepend : :append
      end

      Entity_Removed = Callback_::Event.prototype_with(  # [#035]:B

        :entity_removed,

        :entity, nil,
        :entity_collection, nil,

        :is_completion, true,  # remember this? hehe
        :ok, true

      ) do | y, o |

        a = [ 'removed' ]  # (one day [#035]:WISH-A EN-like expression adapters)

        s = o.entity.description_under self
        a.push s || 'component'

        acs = o.entity_collection
        s = acs.description_under self
        if ! s
          # transitional hack while #open [#035] (preview of what's next)
          s = acs.name.as_human
        end
        a.push 'from', s

        y << ( a * SPACE_ )
      end
  end

  module Event_Support_  # publicize if needed. stowaway.

    rx = nil
    Ick_if_necessary_of_under = -> s, expag do
      rx ||= /\A['"]/
      if rx =~ s
        s
      else
        expag.calculate do
          ick s
        end
      end
    end
  end
end
