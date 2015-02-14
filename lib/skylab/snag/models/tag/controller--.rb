module Skylab::Snag

  class Models::Tag

    class Controller__  # a kernel - CAN HAVE INVALID PROPERTIES

      def initialize lstn
        @delegate = lstn
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
        x = nil

        ok_arg = Tag_::Stem_Normalization_.
            normalize_argument_value @stem_i do | * i_a, & ev_p |

          x = if :error == i_a.first
            @delegate.receive_error_event ev_p[]
          else
            @delegate.receive_info_event ev_p[]
          end
          nil
        end
        @last_callback_result = x

        if ok_arg
          @is_valid = true
          @stem_i = ok_arg.value_x
        else
          @is_valid = false
        end
        nil
      end

      def say_not_valid
        "sanity - invalid operation: tag is not valid."
      end
    end
  end
end
