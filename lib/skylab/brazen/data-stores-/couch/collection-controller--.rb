module Skylab::Brazen

  class Data_Stores_::Couch

    class Collection_Controller__

      # frontier class. will be abstracted later

      def initialize five
        @datastore_i, @channel, @delegate, @model_class, @kernel = five
        @did_resolve_connection = false
        @did_add_view_document = false
      end

      def to_property_hash_scan
        require_connection
        @connection and via_connection_get_property_hash_scan
      end

    private

      def via_connection_get_property_hash_scan
        h = retrieve_payload
        h and get_property_hash_scan_via_payload_h h
      end

      def retrieve_payload
        _s = get_view_document_URI_tail
        @connection.get _s, :delegate, self, :channel, :retrieve_payload
      end

      def retrieve_payload_when_200_ok o
        Lib_::JSON[].parse o.response.body
      end

      def retrieve_payload_when_404_object_not_found o
        if @did_add_view_document
          ev = o.response_body_to_error_event
          send_error ev ; nil
        else
          @did_add_view_document = true
          add_view_document
        end
      end

      def add_view_document
        _ick = { views: { vu1: { map: "function(doc) { #{
        }if (doc.entity_model) { emit( doc.entity_model, doc.properties ); } }"
        } } }
        _body = Lib_::JSON[].pretty_generate _ick
        @connection.put _body, :entity_identifier_strategy, :append_URI_tail,
          :URI_tail, '_design/vu',
          :delegate, self, :channel, :add_view_document
      end

      def add_view_document_when_201_created o
        _ev = o.response_body_to_completion_event do |y, ev|
          y << "added design document #{ val ev.id }"
        end
        @delegate.send :"receive_#{ @channel }_info", _ev
        retrieve_payload  # "try again" i really hate this here.
      end

      def get_property_hash_scan_via_payload_h h
        Entity_[].scan_nonsparse_array( h[ 'rows' ] ).map_by do |x|
          x.fetch VALUE__
        end
      end
      VALUE__ = 'value'.freeze

      def get_view_document_URI_tail
        _i = @model_class.name_function.as_lowercase_with_underscores_symbol
        "_design/vu/_view/vu1?key=\"#{ _i }\""
      end

      def require_connection
        @did_resolve_connection or resolve_connection
        @connection
      end

      def resolve_connection
        @did_resolve_connection = true
        _cols = @kernel.datastores[ :couch ]
        @connection =
        _cols.retrieve_entity_via_name @datastore_i, -> ev do
          send_error ev ; UNABLE_
        end ; nil
      end

      def send_error ev
        @delegate.send :"receive_#{ @channel }_error", ev
      end
    end
  end
end
