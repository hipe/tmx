module Skylab::Brazen

  class Data_Stores_::Couch

    class Actors__::Persist < Couch_Actor_

      Actor_[ self, :properties,
        :entity,
        :datastore ]

      def execute
        init_ivars
        ok = rslv_ivars
        ok && prdc_any_result
      end

    private

      def init_ivars
        @dry_run = @entity.any_parameter_value :dry_run
        @property_scan = @entity.to_normalized_actual_property_scan_for_persist
        @response_receiver = me_as_response_receiver
        nil
      end

      def me_as_response_receiver
        Couch_.HTTP_remote.response_receiver.new self
      end

      def rslv_ivars
        via_entity_rslv_native_entity_identifier
      end

      def via_entity_rslv_native_entity_identifier
        ok = via_entity_resolve_entity_identifier
        ok && via_entity_identifier_resolve_native_entity_identifier
      end

      def prdc_any_result
        if @entity.came_from_persistence
          rslv_result_when_update
        else
          rslv_result_when_create
        end
      end

      def rslv_result_when_update
        self._DO_ME
      end

      def rslv_result_when_create
        _h = bld_entity_as_document_h
        _s = _JSON.pretty_generate _h

        @datastore.put _s,
          :native_entity_identifier_s, @native_entity_identifier_s,
          :entity_identifier_strategy, :native_entity_identifier_string,
          :response_receiver, @response_receiver  # is some
      end

      def bld_entity_as_document_h

        h = { entity_model: @entity_identifier.silo_name_i,
              properties: ( h_ = {} ) }

        while actual = @property_scan.gets
          h_[ actual.name_i ] = actual.value_x
        end

        h
      end

      def when_201_created o
        _ev = o.response_body_to_completion_event do |y, o_|
          y << "created #{ val o_.id } (rev: #{ val o_.rev })"
        end
        any_result_via_send _ev
      end

      def when_404_object_not_found o
        ds_i = @datastore_i.to_s
        _ev = o.response_body_to_not_OK_event do |y, ev|
          y << "there is no #{ val ds_i } couch datastore (#{ val ev.reason })"
        end
        any_result_via_send _ev
      end

      def when_409_conflict o
        _eid = @native_entity_identifier_s
        _ev = o.response_body_to_not_OK_event :name, _eid do |y, ev|
          y << "#{ val ev.name } is already taken as a name #{
           }(#{ o.response.code } #{ ev.reason })"
        end
        any_result_via_send _ev
      end

      def when_412_precondition_failed o
        any_result_via_send o.response_body_to_not_OK_event
      end

      def when_500_internal_server_error o
        _ev = o.response_body_to_not_OK_event
        any_result_via_send _ev
      end

      def any_result_via_send ev
        send_event ev
      end

      def event_receiver
        @entity
      end
    end
  end
end
