module Skylab::Snag

  class Models_::Node

    class Actions::ToStream

      def definition ; [

        :property, :identifier,
        :normalize_by, -> x, & p do
          _kn = Normalize_ID_[ x, & p ]
          _kn  # #hi. #todo  #here
        end,

        :property, :number_limit,
        :must_be_integer_greater_than_or_equal_to, 1,
        :description, -> y do
          y << 'limit output to N nodes'
        end,

        :required, :property, :upstream_identifier
      ] end


      def initialize
        extend NodeRelatedMethods, ActionRelatedMethods_
        init_action_ yield
        @identifier = nil  # #[#026]
      end

      def execute
        if resolve_node_collection_
          __via_node_collection
        end
      end

      def __via_node_collection

        if @identifier
          __when_identifier
        else
          __when_not_identifier
        end
      end

      def __when_identifier

        @identifier.respond_to?( :suffix ) || self._SANITY  # assume normalized #here

        _ = @_node_collection_.entity_via_identifier_object @identifier, & _listener_
        _  # #todo
      end

      def __when_not_identifier

        _ = @_node_collection_.to_entity_stream( & _listener_ )
        if _store_ :@_node_stream, _
          __via_node_stream
        end
      end

      def __via_node_stream
        if @number_limit
          __when_number_limit
        else
          remove_instance_variable :@_node_stream
        end
      end

      def __when_number_limit

        count = 0

        Common_::Stream.by @_node_stream.upstream do

          if @number_limit > count
            x = @_node_stream.gets
            x and count += 1
            x
          end
        end
      end

      # ==
    end
  end
end
