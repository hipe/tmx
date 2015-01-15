module Skylab::MetaHell

  module Parse

    class Functions_::Keyword < Parse_::Function_::Field

      class << self
        def new_via_iambic_stream_passively st
          new do
            @formal_token_string = st.gets_one  # magic first token
            process_iambic_stream_passively st  # always OK
          end
        end
      end  # >>

      edit_actor_class :properties,
        :formal_token_string,
        :minimum_number_of_characters

      def initialize
        super
        @moniker_symbol = @formal_token_string.intern
        @minimum_number_of_characters ||= 1
        @formal_token_length = @formal_token_string.length
        @acceptable_input_token_length_range =
          @minimum_number_of_characters .. @formal_token_length
      end

      def to_matcher
        p = self
        -> input_token_s do
          output_token = p.call Parse_::Input_Streams_::Single_Token.new input_token_s
          if output_token
            output_token.value_x  # sanity
            true
          end
        end
      end

      def call in_st
        if in_st.unparsed_exists
          tok_o = in_st.current_token_object
          tok_s = tok_o.value_x
          input_token_length = tok_s.length
          if @acceptable_input_token_length_range.include? input_token_length
            if @formal_token_string[ 0, input_token_length ] == tok_s
              in_st.advance_one
              Parse_::Output_Node_.new @moniker_symbol
            end
          end
        end
      end
    end
  end
end
