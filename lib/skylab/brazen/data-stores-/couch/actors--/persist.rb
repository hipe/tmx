module Skylab::Brazen

  class Data_Stores_::Couch

    class Actors__::Persist < Couch_Actor_

      Actor_[ self, :properties,
        :entity, :datastore_i, :kernel ]

      def execute
        ok = via_datastore_name_resolve_datastore
        ok && init_ivars
        ok &&= resolve_ivars
        ok && via_datastore_resolve_result
        @result
      end

    private

      def init_ivars
        via_entity_init_action_properties
        @entity_model_i = @entity.class.name_function.as_lowercase_with_underscores_symbol
        @scn = @entity.to_normalized_actual_property_scan ; nil
      end

      def resolve_ivars
        resolve_entity_identifier
      end

      def resolve_entity_identifier
        @name = @entity.property_value :name
        if NATURAL_KEY_RX__ =~ @name
          _s_ = @entity.class.name_function.as_slug
          @entity_identifier = "#{ _s_ }--#{ @name }"
          ACHEIVED_
        else
          resolve_result_via_error_with :name_is_invalid_as_a_natural_key,
            :name, @name
          UNABLE_
        end
      end
      NATURAL_KEY_RX__ = /\A[-a-z0-9]+\z/

      def via_datastore_resolve_result
        if @entity.came_from_persistence
          resolve_result_when_update
        else
          resolve_result_when_create
        end
      end

      def resolve_result_when_update
        self._DO_ME
      end

      def resolve_result_when_create
        h = { entity_model: @entity_model_i, properties: ( h_ = {} ) }
        while actual = @scn.gets
          h_[ actual.name_i ] = actual.value_x
        end
        s = Lib_::JSON[].pretty_generate h
        @datastore.put s, :delegate, self,
          :entity_identifier, @entity_identifier,
          :entity_identifier_strategy, :entity_identifier ; nil
      end

      def when_201_created o
        _ev = o.response_body_to_completion_event do |y, o_|
          y << "created #{ val o_.id } (rev: #{ val o_.rev })"
        end
        resolve_result_via_success_event _ev
      end

      def when_404_object_not_found o
        ds_i = @datastore_i.to_s
        _ev = o.response_body_to_error_event do |y, ev|
          y << "there is no #{ val ds_i } couch datastore (#{ val ev.reason })"
        end
        resolve_result_via_error _ev
      end

      def when_409_conflict o
        _eid = @entity_identifier
        _ev = o.response_body_to_error_event :name, @name do |y, ev|
          y << "#{ val ev.name } is already taken as a name #{
           }(#{ o.response.code } #{ ev.reason })"
        end
        resolve_result_via_error _ev
      end

      def when_412_precondition_failed o
        resolve_result_via_error o.response_body_to_error_event
      end

      def when_500_internal_server_error o
        _ev = o.response_body_to_error_event
        resolve_result_via_error _ev
      end

      def listener
        @entity
      end
    end
  end
end
