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
        ACHIEVED_
      end
    end

    Byte_Stream_Singleton_Methods__ = ::Module.new

    module Byte_Upstream_Identifier  # :[#018].

      class << self

        def via_path s
          Home_.lib_.system_lib::Filesystem::Byte_Upstream_Identifier.new s
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

        def via_qualified_knownnesses qkn_a, & oes_p
          o = __method_call_via_shape qkn_a, & oes_p
          o and send o.method_name, * o.args
        end
      end  # >>

      extend Byte_Stream_Singleton_Methods__
    end

    Byte_downstream_identifier_via_mixed = -> x do

      # the counterpart to [#ca-056]

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
          Home_.lib_.system_lib::Filesystem::Byte_Downstream_Identifier.new s
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

        def via_qualified_knownnesses qualified_knownness_a, & oes_p
          o = __method_call_via_shape qualified_knownness_a, & oes_p
          o and send o.method_name, * o.args
        end

        def via_yielder yld
          Home_.lib_.basic::Yielder::Byte_Downstream_Identifier.new yld
        end
      end  # >>

      extend Byte_Stream_Singleton_Methods__
    end

    module Byte_Stream_Singleton_Methods__

      def __method_call_via_shape qualified_knownness_a, & oes_p
        Byte_stream_method_call_via_shape___.new( qualified_knownness_a, & oes_p ).execute
      end
    end

    class Byte_stream_method_call_via_shape___

      def initialize qualified_knownness_a, & oes_p
        @arg = qualified_knownness_a.fetch 0
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

          Common_::Bound_Call.via_args_and_method_name @x, :via_path

        elsif @x.respond_to? :each_with_index

          Common_::Bound_Call.via_args_and_method_name [ @x ], :via_line_array

        else
          stream
        end
      end

      def stream
        Common_::Bound_Call.via_args_and_method_name @x, :via_stream
      end

      def string
        Common_::Bound_Call.via_args_and_method_name @x, :via_string
      end
    end

    DIRECTION_SHAPE_RX = /\A(?<direction>.+)_(?<shape> path | stream | string )\z/x

    class Common_fuzzy_retrieve

      # (this node is an interesting case study)

      class << self

        def _call kn, stream_builder, & oes_p

          o = new( & oes_p )

          o.found_map = -> x do
            x.dup  # flyweights
          end

          o.name_map = -> x do
            x.name.as_slug
          end

          o.qualified_knownness = kn

          o.stream_builder = stream_builder

          o.execute
        end

        alias_method :[], :_call
        alias_method :call, :_call
      end  # >>

      def initialize & oes_p

        @be_case_sensitive = false
        @found_map = nil
        @levenshtein_number = nil
        @name_map = nil
        @on_event_selectively = oes_p
        @success_map = nil
        @suffixed_contextualization_message_proc = nil
        @target_map = nil
      end

      attr_writer(

        :found_map,  # each candidate that is matched off the input stream
        # (even when more than one) is mapped through this optional mapper.
        # this is typically used to un-flyweight a flyweight, so error-
        # reporting works in cases of ambiguity.

        :levenshtein_number,  # if provided, will be used to reduce the
        # number of items in the "did you mean [..]?"-type expressions.

        :name_map,  # how do we resolve a string-like name from each
        # candidate item? if not provided, the assumption is that the
        # candidate items are string-like (or perhaps only that they are
        # `=~` compatible.)

        :on_event_selectively,  # (required) a [#ca-001] selective listener
        # proc to call in case not exactly one match can be resolved.

        :qualified_knownness,  # (required) wrap your target value in
        # this [#ca-004] which associates a name function with the value.

        :be_case_sensitive,  # case sensitivity is OFF by default

        :stream_builder,  # (required) build the candidate stream. we need
        # a builder and not the stream itself because in case one match
        # is not resolved, we need the whole stream anew to report on it.

        :success_map,  # if exactly one match is resolved from the stream
        # of items, before it is presented as the final result it will be
        # mapped through this proc if provided.

        :target_map,  # for the purposes of matching each candidate against
        # the target value (in the qkn), alter the target in this way


        :suffixed_contextualization_message_proc,
      )

      def set_qualified_knownness_value_and_symbol x, sym
        @qualified_knownness =
          Common_::Qualified_Knownness.via_value_and_symbol x, sym
        NIL_
      end

      def set_qualified_knownness_value_and_name x, nf
        @qualified_knownness =
          Common_::Qualified_Knownness.via_value_and_association x, nf
      end

      def execute

        x = @qualified_knownness.value_x

        if @target_map
          x = @target_map[ x ]
        end

        o = Home_.lib_.basic::Fuzzy.begin
        o.string = x
        o.stream = @stream_builder.call
        o.candidate_map = @name_map
        o.result_map = @found_map
        o.be_case_sensitive = @be_case_sensitive
        a = o.execute

        case 1 <=> a.length
        when 0
          x = a.fetch 0
          if @success_map
            @success_map[ x ]
          else
            x
          end

        when 1
          __not_found

        when -1
          ___ambiguous a
        end
      end

      def ___ambiguous a

        @on_event_selectively.call :error, :ambiguous_property do
          Home_.lib_.fields::Events::Ambiguous.new_via(
            a,
            @qualified_knownness.value_x,
            @qualified_knownness.name,
            & @name_map
          )
        end

        UNABLE_
      end

      def __not_found

        @on_event_selectively.call :error, :extra_properties do

          kn = @qualified_knownness
          name_map = @name_map
          _st = @stream_builder.call

          did_you_mean_s_a = _st.map_by do | ent |
            name_map[ ent ]
          end.to_a

          d = @levenshtein_number
          if d
            _Lev = Home_.lib_.human::Levenshtein
            a = _Lev.with(
              :item, kn.value_x,
              :items, did_you_mean_s_a,
              :closest_N_items, d,
            )
            if a && a.length.nonzero?
              did_you_mean_s_a = a
            end
          end

          Home_.lib_.fields::Events::Extra.new_with(
            :name_x_a, [ kn.value_x ],
            :did_you_mean_i_a, did_you_mean_s_a,
            :lemma, kn.name.as_human,
            :suffixed_prepositional_phrase_context_proc,
              @suffixed_contextualization_message_proc,
          )
        end

        UNABLE_
      end
    end
  end
end
