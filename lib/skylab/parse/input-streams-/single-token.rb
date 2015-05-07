module Skylab::MetaHell

  module Parse

    class Input_Streams_::Single_Token

      def initialize x
        @is_hot = true
        @current_token_object = Parse_::Input_Stream_::Token.new x
      end

      attr_reader :current_token_object

      def unparsed_exists
        @is_hot
      end

      def current_index
        @is_hot ? 0 : 1
      end

      def advance_one
        @is_hot = false
        @current_token_object = nil
        nil
      end
    end
  end
end
