module Skylab::MetaHell

  module Parse

    class Input_Streams_::Array

      # largely redundant with [#ca-046] but some important differences.
      # it is less confusing and less room for error if we just rewrite
      # the commonalities and keep the graphs separate (for now).

      def initialize x_a
        @d = 0
        @token_cache_a = []
        @x_a = x_a
        @x_a_length = x_a.length
      end

      def gets_one
        x = current_token_object
        advance_one
        x
      end

      def no_unparsed_exists
        @x_a_length == @d
      end

      def unparsed_exists
        @x_a_length != @d
      end

      def current_token
        current_token_object.value_x
      end

      def current_token_object
        if ! @token_cache_a[ @d ]  # sure, let it be sparse, why not
          @token_cache_a[ @d ] = Parse_::Input_Stream_::Token.new @x_a.fetch @d
        end
        @token_cache_a.fetch @d
      end

      def current_index
        @d
      end

      def current_index= x  # assume is valid index
        @d = x ; nil
      end

      def advance_one
        @d += 1 ; nil
      end

      define_singleton_method :the_empty_stream, -> do
        p = -> do
          x = new EMPTY_A_
          def x.current_index= d
            if @d != d
              super
            end
          end
          p = -> { x }
          x.freeze
        end
        -> do
          p[]
        end
      end.call
    end
  end
end
