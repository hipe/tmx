module Skylab::Brazen

  class Data_Stores_::Couch

    class Actors__::Build_stream < Couch_Actor_

      Actor_[ self, :properties,
        :model_class,
        :datastore,
        :kernel, :on_event_selectively ]

      def execute
        init_ivars
        h = retrieve_payload
        h and get_property_hash_scan_via_payload_h h
      end

      def init_ivars
        @two_times = true
        @did_attempt_to_add_view_document = false
        init_response_receiver_for_self_on_channel :my_face
      end

      def retrieve_payload
        while @two_times
          h = try_retrieve_payload
        end
        h
      end

      def try_retrieve_payload
        @two_times = false
        _s = view_document_URI_tail
        @datastore.get _s, :response_receiver, @response_receiver
      end

      def view_document_URI_tail
        @vdut ||= get_view_doc_URI_tail
      end

      def get_view_doc_URI_tail
        _i = @model_class.node_identifier.silo_name_i
        "_design/vu/_view/vu1?key=\"#{ _i }\""
      end

      def attempmt_to_add_view_document
        @did_attempt_to_add_view_document = true
        @two_times = true

        _ick_h = bld_view_document_hash

        _body = _JSON.pretty_generate _ick_h

        _rr = @response_receiver.new_with :channel, :my_face

        @datastore.put _body,
          :entity_identifier_strategy, :append_URI_tail,
          :URI_tail, '_design/vu',
          :response_receiver, _rr
      end

      def bld_view_document_hash  # eek
        { views: {
            vu1: {
              map: "function( doc ) {#{
                   } if ( doc.entity_model ) {#{
                     } emit( doc.entity_model, doc.properties ); } }" } } }
      end

      def when_give_up
        _ev = o.response_body_to_not_OK_event
        send_error _ev
        UNABLE_
      end

      def get_property_hash_scan_via_payload_h h
        fly = @model_class.new_flyweight @kernel, & @on_event_selectively
        box = fly.properties
        Callback_::Stream.via_nonsparse_array( h[ ROWS__ ] ).map_by do |x|
          box.replace_hash x.fetch VALUE__
          fly
        end
      end
      ROWS__ = 'rows'.freeze ; VALUE__ = 'value'.freeze

      def my_face_when_500_internal_server_error o
        maybe_send_event :error do
          o.response_body_to_not_OK_event
        end
        UNABLE_
      end

      def my_face_when_404_object_not_found o
        if @did_attempt_to_add_view_document
          when_give_up
        else
          attempmt_to_add_view_document
        end
      end

      def my_face_when_201_created o
        maybe_send_event :success do
          o.response_body_to_completion_event do |y, ev|
            y << "added design document #{ val ev.id }"
          end
        end
        CONTINUE_
      end
    end
  end
end