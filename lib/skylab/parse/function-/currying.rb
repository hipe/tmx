module Skylab::Parse

  # ->

    class Function_::Currying

      class << self

        def build_extra_input_tokens_event st
          Extra_Input___[ st.current_token_object.value_x ]
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

      def process_iambic_stream_passively st

        # :+#experimental custom syntax - enclosing a flat list of
        # constituents in an array: nicer than a `end_functions` token?

        a = ::Array.try_convert st.current_token
        if a

          st.advance_one

          _st = Callback_::Polymorphic_Stream.new 0, a

          _process_functions_via_polymorphic_stream _st
        else
          super
        end
      end

    private

      def input_array=
        @input_stream = _input_stream_via_array iambic_property
        KEEP_PARSING_
      end

      def matcher_functions=
        st = polymorphic_upstream
        @function_a = []
        cls = Parse_::Functions_::Simple_Matcher
        while st.unparsed_exists
          @function_a.push cls.new_via_proc st.gets_one
        end
        KEEP_PARSING_
      end

      def functions=

        _process_functions_via_polymorphic_stream polymorphic_upstream
      end

      def _process_functions_via_polymorphic_stream st

        @function_a = []

        st_ = __produce_parse_function_stream_via_polymorphic_stream st

        begin
          f = st_.gets
          f or break
          accept_function_ f
          redo
        end while nil

        UNABLE_ != f
      end

      def __produce_parse_function_stream_via_polymorphic_stream st

        Callback_.stream do
          if st.unparsed_exists
            sym = st.gets_one
            if :end_functions == sym
              nil  # not false
            else
              Parse_.function( sym ).new_via_iambic_stream_passively st
            end
          end
        end
      end

      def accept_function_ f
        @function_a.push f
        nil
      end

      def maybe_send_sibling_sandbox_to_function_ f  # #courtesy
        if f.respond_to? :receive_sibling_sandbox
          @__ss ||= Function_::Nonterminal::Sibling_Sandbox.new @function_a
          f.receive_sibling_sandbox @__ss
          nil
        end
      end

      def function_objects_array=
        @function_a = iambic_property
        KEEP_PARSING_
      end

    public

      def execute
        @function_a.freeze
        if @input_stream  # then this function is an inline one-off
          parse_
        else
          freeze
        end
      end

      def express_all_segments_into_under y, * x_a

        Parse_::Function_::Nonterminal::Sessions::Express.session do | o |

          case 1 <=> x_a.length
          when  0
            o.set_expression_agent x_a.fetch 0
          when -1
            o.accept_iambic x_a
          end

          if o.constituent_delimiter_pair_should_be_specified
            o.set_constituent_delimiter_pair( *
              constituent_delimiter_pair_for_expression_agent(
                o.expression_agent ) )
          end

          o.set_reflective_function_stream(
            Callback_::Stream.via_nonsparse_array @function_a )

          o.set_downstream y
        end
      end

      def to_reflective_function_stream_  # for above
        Callback_::Stream.via_nonsparse_array @function_a
      end

      def to_parse_array_fully_proc

        -> argv do

          in_st = _input_stream_via_array argv

          on = output_node_via_input_stream in_st

          if in_st.unparsed_exists
            raise self.class.build_extra_input_tokens_event( in_st ).to_exception
          else
            on.value_x
          end
        end
      end

      def parse_and_mutate_array a
        _output_node_and_mutate_array( a ).value_x  # until this doesn't work
      end

      def to_output_node_and_mutate_array_proc
        method :_output_node_and_mutate_array
      end

      def _output_node_and_mutate_array a
        st = _input_stream_via_array a
        d = st.current_index
        on = output_node_via_input_stream st
        positive_delta = st.current_index - d
        if positive_delta.nonzero?
          a[ 0, positive_delta ] = EMPTY_A_
        end
        on
      end

      def output_node_via_input_array_fully a
        st = _input_stream_via_array a
        on = output_node_via_input_stream st
        if on and ! st.unparsed_exists
          on
        end
      end

      def output_node_via_single_token_value x
        output_node_via_input_stream _input_stream_via_array [ x ]
      end

      def output_node_via_input_stream in_st
        dup.__init_for_parse( in_st ).parse_
      end

    protected

      def __init_for_parse in_st
        @input_stream = in_st
        self
      end

    private

      def _input_stream_via_array a
        Parse_::Input_Streams_::Array.new a
      end

    end
    # <-
end
