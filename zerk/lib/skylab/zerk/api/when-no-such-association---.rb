module Skylab::Zerk

  module API

    # -

      When_no_such_association___ = -> ss, arg_st do

        Require_field_library_[]

        _st = ss.last.to_node_stream_for_invocation_

        _st_ = _st.map_by do |qk|
          qk.name.as_variegated_symbol
        end

        _st__ = _st_.flush_to_polymorphic_stream

        o = Field_::MetaAttributes::Enum::Build_extra_value_event.new

        o.invalid_value = arg_st.current_token

        o.valid_collection = _st__

        o.property_name = Callback_::Name.via_human 'association'

        o.event_name_symbol = :no_such_association

        o.adjective = 'no such'

        o.valid_value_mapper_from = -> expag do
          -> sym do
            expag.calculate do
              parameter_in_black_and_white sym.id2name
            end
          end
        end

        o.execute
      end
    # ->
  end
end
