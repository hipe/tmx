module Skylab::MetaHell

  module Parse

    class Functions_::Keyword

      class << self

        # ~ narrative (not alpha) order

        def new_via_arglist a
          st = Callback_::Iambic_Stream.via_array a
          x = new_via_iambic_stream_passively st
          st.unparsed_exists and raise ::ArgumentError, st.current_token
          x
        end

        def new_via_iambic_stream_passively st
          new do
            @formal_token_string = st.gets_one
            process_iambic_stream_passively st  # always OK
          end
        end

      end  # >>

      Callback_::Actor.call self, :properties,
        :formal_token_string,
        :minimum_number_of_characters

      def initialize
        super
        @formal_token_symbol = @formal_token_string.intern
        @minimum_number_of_characters ||= 1
        @formal_token_length = @formal_token_string.length
        @acceptable_input_token_length_range =
          @minimum_number_of_characters .. @formal_token_length
      end

      def to_matcher
        p = self
        -> input_token_s do
          output_token = p[ Parse_::Input_Streams_::Single_Token.new input_token_s ]
          if output_token
            output_token.value_x  # sanity
            true
          end
        end
      end

      def [] in_st
        if in_st.unparsed_exists
          tok_o = in_st.current_token_object
          tok_s = tok_o.value_x
          input_token_length = tok_s.length
          if @acceptable_input_token_length_range.include? input_token_length
            if @formal_token_string[ 0, input_token_length ] == tok_s
              in_st.advance_one
              Parse_::Output_Node_.new @formal_token_symbol
            end
          end
        end
      end
    end
  end
end
