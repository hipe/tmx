module Skylab::MetaHell

  module Parse

    class Input_Streams_::Array

      def initialize x_a
        @d = 0
        @did = false
        @x_a = x_a
        @x_a_length = x_a.length
      end

      def gets_one
        x = current_token_object
        advance_one
        x
      end

      def unparsed_exists
        @x_a_length != @d
      end

      def current_token_object
        if @did
          @token
        else
          @did = true
          @token = Parse_::Input_Stream_::Token.new @x_a.fetch @d
        end
      end

      def current_index
        @d
      end

      def advance_one
        @did = false
        @d += 1 ; nil
      end
    end
  end
end
