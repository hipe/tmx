module Skylab::Brazen

  class Data_Stores_::Couch

    class Actors__::Delete < Couch_Actor_

      Actor_[ self, :properties,
        :entity,
        :datastore,
        :event_receiver ]

      def execute  # any result
        init_ivars
        ok = via_entity_resolve_entity_identifier
        ok &&= via_entity_identifier_resolve_native_entity_identifier
        ok && work
      end

      def init_ivars
        init_response_receiver_for_self_on_channel :my_face
      end

      def work

        @rev = @entity.parameter_value :couch_entity_revision

        @datastore.delete @native_entity_identifier_s,
          :add_HTTP_parameter, :rev, @rev,
          :response_receiver, @response_receiver
      end

      def my_face_when_409_conflict o
        _ev = o.response_body_to_not_OK_event
        send_event _ev
        UNABLE_
      end

      def my_face_when_200_ok response
        _eid = @entity_identifier
        _props = @entity.properties

        _ev = response.response_body_to_completion_event(
          :eid, _eid, :props, _props ) do |y, o|

            y << "removed #{ o.eid.description } #{
              }(rev: #{ ick o.rev }) #{
                }(#{ o.code } #{ o.message })"

        end
        send_event _ev
      end
    end
  end
end
