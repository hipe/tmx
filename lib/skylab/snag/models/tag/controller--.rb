module Skylab::Snag

  class Models::Tag

    class Controller__  # a kernel - CAN HAVE INVALID PROPERTIES

      def initialize lstn
        @listener = lstn
      end

      attr_reader :last_callback_result

      def to_string
        if is_valid
          "##{ @stem_i }"
        else
          raise say_not_valid
        end
      end

      def receive_stem_i x
        @is_validated = false
        @stem_i = x ; nil
      end

      def is_valid
        @is_validated || validate
        @is_valid
      end

    private

      def validate
        @is_validated = true
        o = Tag_::Stem_Normalization_.new @listener
        o.stem_i = @stem_i
        if o.is_valid
          @is_valid = true
          @stem_i = o.stem_i
        else
          @is_valid = false
        end
        @last_callback_result = o.result_of_last_callback_called
        nil
      end

      def say_not_valid
        "sanity - invalid operation: tag is not valid."
      end
    end
  end
end
