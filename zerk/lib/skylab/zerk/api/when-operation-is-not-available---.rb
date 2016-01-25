module Skylab::Zerk

  module API

    # -

      Require_field_library_[]

      When_operation_is_not_available___ = -> fo do

        o = Fields_::MetaMetaFields::Enum::Build_extra_value_event.new

        o.adjective = nil  # override 'invalid'

        o.event_name_symbol = :operation_not_available

        o.property_name = Callback_::Name.via_human 'operation'

        o.invalid_value = fo.name.as_slug

        o.predicate_string = 'is not available'

        o.valid_collection = nil

        o.execute
      end
    # ->
  end
end

