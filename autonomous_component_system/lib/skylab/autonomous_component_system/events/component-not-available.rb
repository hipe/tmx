module Skylab::Zerk

  module API

    # -

      Require_field_library_[]

      When_association_is_not_available___ = -> ss, asc do

        o = Fields_::MetaMetaFields::Enum::Build_extra_value_event.new

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
    # ->
  end
end


