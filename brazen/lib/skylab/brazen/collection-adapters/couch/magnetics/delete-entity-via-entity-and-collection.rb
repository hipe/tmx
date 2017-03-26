module Skylab::Brazen

  class Collection_Adapters::Couch

    class Magnetics::DeleteEntity_via_Entity_and_Collection < CouchMagnetic_

      Attributes_actor_.call( self,
        :action,
        :entity,
        :collection,
      )

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

        @rev = @entity.couch_entity_revision_

        @collection.delete @native_entity_identifier_s,
          :add_HTTP_parameter, :rev, @rev,
          :response_receiver, @response_receiver
      end

      def my_face_when_409_conflict o
        maybe_send_event :error, :conflict do
          o.response_body_to_not_OK_event
        end
        UNABLE_
      end

      def my_face_when_200_ok response
        maybe_send_event :success do
          bld_success_event response
        end
      end

      def bld_success_event response
        _eid = @entity_identifier
        _props = @entity.properties

        response.response_body_to_completion_event(
          :eid, _eid, :props, _props ) do |y, o|

            y << "removed #{ o.eid.description } #{
              }(rev: #{ ick o.rev }) #{
                }(#{ o.code } #{ o.message })"

        end
      end
    end
  end
end
