module Skylab::Snag

  class Models::Tag

    class Stem_Normalization_
      # [#043] employs case sensitivity, [#017] results in callback's result

      def initialize listener=Snag_::Model_::THROWING_INFO_ERROR_LISTENER
        @listener = listener
      end

      attr_reader :result_of_last_callback_called, :stem_i

      def stem_i= x
        with_tag_s "##{ x }"
        @stem_i = x  # be careful
      end

      def with_tag_s tag_s
        will_change
        @tag_s = tag_s
        self
      end

      def valid
        if is_valid
          self
        else
          false
        end
      end

      def is_valid
        @is_validated or validate
        @is_valid
      end

    private
      def will_change
        @is_validated = @is_valid = false ; nil
      end

      def validate
        @is_validated = true
        @scn = Models::Hashtag.scanner @tag_s
        @symbol = @scn.gets
        if @symbol && :hashtag == @symbol.symbol_i
          check_the_rest
        else
          result_in_invalid_error
        end ; nil
      end

      def check_the_rest
        @xtra = @scn.gets
        if @xtra
          when_unexpected_trailing_content
        else
          accept_validity
        end
      end

      def when_unexpected_trailing_content
        result_in_invalid_error
      end

      def accept_validity
        @stem_i = @symbol.get_stem_s.intern
        @is_valid = true ; nil
      end

      def value_changed
        if @listener.info_p
          _ev = Changed__.new @unsanitized_stem_i, out_s.intern
          @result_of_last_callback_called = @listener.receive_info_event _ev
        end ; nil
      end
      Changed__ = Event_[].new :from_i, :to_i do
        message_proc do |y, o|
          y << "changed #{ ick o.from_i } to #{ ick o.to_i }"
        end
      end

      def result_in_invalid_error
        result_in_error Invalid__.new @tag_s
      end
      Invalid__ = Event_[].new :tag_s do
        message_proc do |y, o|
          y << "tag must be alphanumeric separated with dashes - #{
           }invalid tag name: #{ ick o.tag_s }"
        end
      end

      def result_in_error ev
        @result_of_last_callback_called = @listener.receive_error_event ev
        nil
      end
    end
  end
end
