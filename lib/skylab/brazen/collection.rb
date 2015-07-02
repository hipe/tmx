module Skylab::Brazen

  module Collection

    class Model_ < Brazen_::Model

      NAME_STOP_INDEX = 1  # sl brzn dratastore actions couch add

    end

    class Action < Brazen_::Action

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

        def via_path s
          Brazen_.lib_.system.filesystem.class::Byte_Upstream_Identifier.new s
        end

        def via_stream io
          Brazen_.lib_.IO_lib::Byte_Upstream_Identifier.new io
        end

        def via_line_array s_a
          Brazen_.lib_.basic::List::Byte_Upstream_Identifier.new s_a
        end

        def via_string s
          Brazen_.lib_.basic::String::Byte_Upstream_Identifier.new s
        end

        def via_trios trio_a, & oes_p
          o = __method_call_via_shape trio_a, & oes_p
          o and send o.method_name, * o.args
        end
      end  # >>

      extend Byte_Stream_Singleton_Methods__
    end

    Byte_downstream_identifier_via_mixed = -> x do

      # the counterpart to [#cb-056]

      if x.respond_to? :push

        Byte_Downstream_Identifier.via_line_array x

      elsif x.respond_to? :puts

        Byte_Downstream_Identifier.via_stream x

      elsif x.respond_to? :ascii_only?

        Byte_Downstream_Identifier.via_string x

      elsif x.respond_to? :yield

        Byte_Downstream_Identifier.via_yielder x
      end
    end

    module Byte_Downstream_Identifier

      class << self

        def the_dry_identifier
          self._WHY
          LIB_.IO.dry_stub.the_dry_byte_downstream_identifier
        end

        def via_path s
          Brazen_.lib_.system.filesystem.class::Byte_Downstream_Identifier.new s
        end

        def via_stream io
          Brazen_.lib_.IO_lib::Byte_Downstream_Identifier.new io
        end

        def via_line_array s_a
          Brazen_.lib_.basic::List::Byte_Downstream_Identifier.new s_a
        end

        def via_string s
          Brazen_.lib_.basic::String::Byte_Downstream_Identifier.new s
        end

        def via_trios trio_a, & oes_p
          o = __method_call_via_shape trio_a, & oes_p
          o and send o.method_name, * o.args
        end

        def via_yielder yld
          Brazen_.lib_.basic::Yielder::Byte_Downstream_Identifier.new yld
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
        # to be able to pass stream-like mixed values in for a path.

        if @x.respond_to? :ascii_only?

          Callback_::Bound_Call.via_args_and_method_name @x, :via_path

        elsif @x.respond_to? :each_with_index

          Callback_::Bound_Call.via_args_and_method_name [ @x ], :via_line_array

        else
          stream
        end
      end

      def stream
        Callback_::Bound_Call.via_args_and_method_name @x, :via_stream
      end

      def string
        Callback_::Bound_Call.via_args_and_method_name @x, :via_string
      end
    end

    DIRECTION_SHAPE_RX = /\A(?<direction>.+)_(?<shape> path | stream | string )\z/x

    class Common_fuzzy_retrieve

      name_map = -> o do
        o.name.as_slug
      end

      p = -> trio, col, & oes_p do

        x = trio.value_x

        if x.respond_to? :id2name
          self._DO_ME_exact_match
        else

          _st = col.to_entity_stream
          _lib = Brazen_.lib_.basic::Fuzzy

          o_a = _lib.reduce_to_array_stream_against_string(
            _st,
            x,
            name_map,
            -> ent do
              ent.dup
            end )

          case 1 <=> o_a.length
          when 0
            o_a.fetch 0

          when 1
            new( col, name_map ).__not_found trio, & oes_p

          when -1
            new( col, name_map ).__ambiguous o_a, trio, & oes_p
          end
        end
      end

      define_singleton_method :call, p
      define_singleton_method :[], p

      def initialize col, p
        @_col = col
        @_name_map = p
      end

      def __ambiguous o_a, trio, & oes_p

        oes_p.call :error, :ambiguous_property do
          Brazen_::Property.build_ambiguous_property_event(
            o_a,
            trio.value_x,
            trio.name )
        end
      end

      def __not_found trio, & oes_p

        oes_p.call :error, :extra_properties do

          _did_you_mean_s_a = @_col.to_entity_stream.map_by do | ent |
            ent.name.as_slug
          end.to_a

          Brazen_::Property.build_extra_values_event(
            [ trio.value_x ],
            _did_you_mean_s_a,
            trio.name.as_human )
        end
      end
    end
  end
end
