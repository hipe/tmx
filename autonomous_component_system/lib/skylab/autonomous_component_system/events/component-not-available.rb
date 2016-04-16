module Skylab::Autonomous_Component_System

  module Events::Component_Not_Available

    Require_fields_lib_[]

    Act = -> unava_p, asc, ss do

      x = unava_p[]
      if false  # oes_p
        # ..
      elsif x
        self._A
      else
        raise Build_event[ ss, asc ].to_exception
      end
    end

    # -

      Build_event = -> ss, asc do

        o = Field_::MetaAttributes::Enum::Build_extra_value_event.new

        o.adjective = nil  # override 'invalid'

        o.event_name_symbol = :association_not_available

        o.property_name = Callback_::Name.via_human 'association'

        a = ss[ 1..-1 ].map do |fr|
          fr.name.as_slug
        end

        a.push asc.name.as_slug

        o.invalid_value = "#{ a.join SPACE_ }"

        o.predicate_string = 'is not available'

        o.valid_collection = nil

        o.execute
      end
    # -
  end
end
