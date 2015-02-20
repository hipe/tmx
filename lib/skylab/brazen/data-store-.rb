module Skylab::Brazen

  module Data_Store_

    class Model_ < Brazen_::Model_

      class << self
        def main_model_class
          superclass.superclass
        end
      end

      NAME_STOP_INDEX = 1  # sl brzn datastore actions couch add

    end

    class Action < Brazen_::Model_::Action

      NAME_STOP_INDEX = 1

    end

    class Actor
    private

      def via_entity_resolve_model_class
        @model_class = @entity.class ; nil
      end

      def via_entity_resolve_entity_identifier
        @entity_identifier = @entity.class.node_identifier.
          with_local_entity_identifier_string @entity.natural_key_string  # #todo - is this covered
        PROCEDE_
      end
    end

    Byte_Stream_Singleton_Methods__ = ::Module.new

    module Byte_Upstream_Identifier  # :[#018].

      class << self

        def via_stream io
          Brazen_.lib_.IO::Byte_Upstream_Identifier.new io
        end

        def via_string s
          Brazen_.lib_.basic::String::Byte_Upstream_Identifier.new s
        end

        def via_path s
          Brazen_.lib_.system.filesystem.class::Byte_Upstream_Identifier.new s
        end

        def via_trios trio_a, & oes_p
          o = __method_call_via_shape trio_a, & oes_p
          o and send o.method_name, * o.args
        end
      end  # >>

      extend Byte_Stream_Singleton_Methods__
    end

    module Byte_Downstream_Identifier

      class << self

        def the_dry_identifier
          self._WHY
          LIB_.IO.dry_stub.the_dry_byte_downstream_identifier
        end

        def via_stream io
          Brazen_.lib_.IO::Byte_Downstream_Identifier.new io
        end

        def via_string s
          Brazen_.lib_.basic::String::Byte_Downstream_Identifier.new s
        end

        def via_path s
          Brazen_.lib_.system.filesystem.class::Byte_Downstream_Identifier.new s
        end

        def via_trios trio_a, & oes_p
          o = __method_call_via_shape trio_a, & oes_p
          o and send o.method_name, * o.args
        end
      end  # >>

      extend Byte_Stream_Singleton_Methods__
    end

    module Byte_Stream_Singleton_Methods__

      def __method_call_via_shape trio_a, & oes_p
        Byte_stream_method_call_via_shape___.new( trio_a, & oes_p ).execute
      end
    end

    class Byte_stream_method_call_via_shape___

      def initialize trio_a, & oes_p
        @arg = trio_a.fetch 0
        @on_event_selectively = oes_p
      end

      def execute
        @x = @arg.value_x
        send DIRECTION_SHAPE_RX.match( @arg.name_symbol )[ :shape ]
      end

      def path

        # :+[#021] shape magic: it is convenient for lazy smart clients
        # to be able to pass stream-like mixed values in for a path

        if @x.respond_to? :ascii_only?
          Brazen_.bound_call @x, nil, :via_path
        else
          stream
        end
      end

      def stream
        Brazen_.bound_call [ @x ], nil, :via_stream
          # argument value might be an array impersonating a stream
      end

      def string
        Brazen_.bound_call @x, nil, :via_string
      end
    end

    DIRECTION_SHAPE_RX = /\A(?<direction>.+)_(?<shape> path | stream | string )\z/x
  end
end
