module Skylab::Zerk

  module API

    # -
      _API_node_stream_for = nil

      When_no_such_association___ = -> up do

        Require_field_library_[]

        _st = _API_node_stream_for[ up.selection_stack.last ]

        _st_ = _st.map_by do |qk|
          qk.name.as_variegated_symbol
        end

        _st__ = _st_.flush_to_polymorphic_stream

        o = Fields_::MetaMetaFields::Enum::Build_extra_value_event.new

        o.invalid_value = up.argument_stream.current_token

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

      _API_node_stream_for = -> frame do

        st = ACS_::For_Interface::To_stream[ frame.value_x ]

        x = frame.__mask__  # #during #open [#013]
        if x
          self._K
        end

        st
      end
    # ->
  end
end
