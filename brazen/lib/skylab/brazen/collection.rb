module Skylab::Brazen

  module Collection

    Model_ = Home_::Model

    Action = Home_::Action

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
          Home_.lib_.system.filesystem.class::Byte_Upstream_Identifier.new s
        end

        def via_stream io
          Home_.lib_.IO_lib::Byte_Upstream_Identifier.new_via_open_IO io
        end

        def via_line_array s_a
          Home_.lib_.basic::List::Byte_Upstream_Identifier.new s_a
        end

        def via_string s
          Home_.lib_.basic::String::Byte_Upstream_Identifier.new s
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
          Home_.lib_.system.filesystem.class::Byte_Downstream_Identifier.new s
        end

        def via_stream io
          Home_.lib_.IO_lib::Byte_Downstream_Identifier.new_via_open_IO io
        end

        def via_line_array s_a
          Home_.lib_.basic::List::Byte_Downstream_Identifier.new s_a
        end

        def via_string s
          Home_.lib_.basic::String::Byte_Downstream_Identifier.new s
        end

        def via_trios trio_a, & oes_p
          o = __method_call_via_shape trio_a, & oes_p
          o and send o.method_name, * o.args
        end

        def via_yielder yld
          Home_.lib_.basic::Yielder::Byte_Downstream_Identifier.new yld
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

      # (this node is an interesting case study)

      class << self

        def _same kn, stream_builder, & oes_p
          new(
            kn,
            stream_builder,
            -> o do
              o.name.as_slug
            end,
            -> o do
              o.dup  # flyweights
            end,
            & oes_p
          ).execute
        end

        alias_method :[], :_same
        alias_method :call, :_same
      end  # >>

      def initialize kn=nil, sb=nil, nm=nil, fm=nil, & oes_p

        @found_map = fm
        @name_map = nm
        @on_event_selectively = oes_p
        @stream_builder = sb
        @qualified_knownness = kn
      end

      attr_writer(
        :found_map,
        :name_map,
        :on_event_selectively,
        :qualified_knownness,
        :stream_builder,
      )

      def execute

        x = @qualified_knownness.value_x

        if x.respond_to? :id2name
          self._DO_ME_exact_match
        else

          a = Home_.lib_.basic::Fuzzy.reduce_to_array_stream_against_string(
            @stream_builder.call,
            x,
            @name_map,
            @found_map,
          )

          case 1 <=> a.length
          when 0
            a.fetch 0

          when 1
            __not_found

          when -1
            __ambiguous a
          end
        end
      end

      def __ambiguous a

        @on_event_selectively.call :error, :ambiguous_property do
          Home_::Property.build_ambiguous_property_event(
            a,
            @qualified_knownness.value_x,
            @qualified_knownness.name,
          )
        end
      end

      def __not_found

        @on_event_selectively.call :error, :extra_properties do

          kn = @qualified_knownness
          name_map = @name_map
          _st = @stream_builder.call

          _did_you_mean_s_a = _st.map_by do | ent |
            name_map[ ent ]
          end.to_a

          Home_::Property.build_extra_values_event(
            [ kn.value_x ],
            _did_you_mean_s_a,
            kn.name.as_human )
        end
      end
    end
  end
end
