module Skylab::Brazen

  class Collection_Adapters::Couch

    Couch_Actor_ = ::Class.new Home_::Collection::Actor

    module Actors__

      class Retrieve_collection_entity < Couch_Actor_

        Attributes_actor_.call( self,
          :entity_identifier,
          :collection,
          :kernel,
        )

        def execute
          init_ivars
          ok = via_entity_identifier_and_kernel_rslv_model_class
          ok &&= via_entity_identifier_resolve_native_entity_identifier
          ok &&= via_native_entity_identifier_rslv_payload_h
          ok && via_payload_h_prdc_entity
        end

      private

        def init_ivars
          init_response_receiver_for_self_on_channel :my_face
        end

        def via_native_entity_identifier_rslv_payload_h
          @payload_h = @collection.get @native_entity_identifier_s,
            :response_receiver, @response_receiver
          @payload_h ? ACHIEVED_ : UNABLE_
        end

        def via_payload_h_prdc_entity

          h = @payload_h.fetch PROPERTIES__
          revision_s = @payload_h.fetch REVISION__

          ent = @model_class.edit_entity @kernel, @on_event_selectively do | o |
            o.edit_pairs h, IDENTITY_, & :intern
          end

          ent and begin
            ent.couch_entity_revision_ = revision_s
            ent
          end
        end

        PROPERTIES__ = 'properties'.freeze ; REVISION__ = '_rev'.freeze

      public

        def my_face_when_404_object_not_found response
          maybe_send_event :error, :not_found do
            bld_not_found_event response
          end
          UNABLE_
        end

        def bld_not_found_event response
          response.response_body_to_not_OK_event :eid, @entity_identifier do |y, o|
            y << "there is no #{ o.eid.silo_name_parts.reverse * SPACE_ }#{
             } with the name #{ ick o.eid.entity_name_string }#{
              } (#{ o.code } - entity not found)"
          end
        end
      end
    end

    class Couch_Actor_
    private

      def init_response_receiver_for_self_on_channel i
        @response_receiver = Couch_.HTTP_remote.response_receiver i, self ; nil
      end

      def via_entity_identifier_resolve_native_entity_identifier
        @name_s = @entity_identifier.name_parts.last
        if NATURAL_KEY_RX__ =~ @name_s
          via_entity_identifier_when_valid_rslv_native_entity_identifier
        else
          when_name_not_valid
        end
      end

      NATURAL_KEY_RX__ = /\A[-a-z0-9]+\z/

      def when_name_not_valid
        send_not_OK_with :name_is_invalid_as_a_natural_key, :name, @name_s
        UNABLE_
      end

      def via_entity_identifier_and_kernel_rslv_model_class

        mc = @kernel.unbound_via(
          :identifier,
          @entity_identifier,
          & @on_event_selectively )

        if mc
          @model_class = mc
          ACHIEVED_
        else
          mc
        end
      end

      def via_entity_identifier_when_valid_rslv_native_entity_identifier

        o = @entity_identifier

        @native_entity_identifier_s =
          "#{ o.silo_slug }--#{ o.entity_name_string }"

        ACHIEVED_
      end

    public

      def my_face_when_200_ok o
        _JSON.parse o.response.body
      end

    private

      def _JSON
        LIB_.JSON
      end
    end
  end
end
