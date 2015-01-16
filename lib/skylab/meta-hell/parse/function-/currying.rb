module Skylab::MetaHell

  module Parse

    class Function_::Currying

      class << self

        def build_extra_input_tokens_event st
          Extra_Input___[ st.current_token_object.value_x ]
        end

        def new_with * x_a
          call_via_iambic x_a
        end
      end  # >>

      Extra_Input___ = Callback_::Event.prototype_with :extra_input,
          :x, nil,
          :error_category, :argument_error do | y, o |

        y << "unrecognized argument #{ ick o.x }"
      end

      Callback_::Actor.methodic self, :simple, :properties,
        :property, :input_stream

      def initialize
        @input_stream = nil
        super
      end

    private

      def matcher_functions=
        st = @__methodic_actor_iambic_stream__
        @function_a = []
        cls = Parse_::Functions_::Simple_Matcher
        while st.unparsed_exists
          @function_a.push cls.new_via_proc st.gets_one
        end
        KEEP_PARSING_
      end

      def functions=
        st = @__methodic_actor_iambic_stream__
        ok_x = true
        @function_a = []
        while st.unparsed_exists
          cls = Parse_.function_ st.gets_one  # if ever needed we can soften this
          ok_x = cls.new_via_iambic_stream_passively st
          ok_x or break

          if ok_x.respond_to? :receive_sibling_sandbox
            @__ss ||= Function_::Nonterminal::Sibling_Sandbox.new @function_a
            ok_x.receive_sibling_sandbox @__ss
          end

          @function_a.push ok_x
        end
        ok_x && KEEP_PARSING_
      end

      def function_objects=
        st = @__methodic_actor_iambic_stream__
        @function_a = []
        while st.unparsed_exists
          @function_a.push st.gets_one
        end
        KEEP_PARSING_
      end

      def function_objects_array=
        @function_a = iambic_property
        KEEP_PARSING_
      end

    public

      def execute
        if @input_stream  # one-off
          @mutable_function_a = @function_a
          @function_a = nil
          parse_
        else
          freeze
        end
      end

      def render_all_segments_into_under y, * x_a
        Parse_::Function_::Nonterminal::Actors::Render[ y, x_a, self ]
      end

      def to_reflective_function_stream_  # for above
        Callback_.stream.via_nonsparse_array @function_a
      end

      def to_parse_array_fully_proc

        -> argv do

          in_st = Parse_::Input_Streams_::Array.new argv

          output_node = call in_st

          if in_st.unparsed_exists
            raise self.class.build_extra_input_tokens_event( in_st ).to_exception
          else
            output_node.value_x
          end
        end
      end

      def parse_and_mutate_array a
        st = Parse_::Input_Streams_::Array.new a
        d = st.current_index
        on = call st
        x = on.value_x
        positive_delta = st.current_index - d
        if positive_delta.nonzero?
          a[ 0, positive_delta ] = EMPTY_A_
        end
        x
      end

      def call in_st
        dup.__init_for_parse( in_st ).parse_
      end

    protected

      def __init_for_parse in_st
        @mutable_function_a = @function_a.dup
        @function_a = nil
        @input_stream = in_st
        self
      end
    end
  end
end
