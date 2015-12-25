require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] core operations - (2) counts" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :operations

    context 'normal case' do

      call_by_ do

        _path = TS_._COMMON_DIR

        call_(
          :ruby_regexp, /[ ]/,
          :path, _path,
          :filename_patterns, EMPTY_A_,
          :search,
          :counts,
        )

        # eek sort of normalize the result we get back from `find` in a way
        # that hopefully won't break when files are added in the future ..

        a = @result.to_a

        h = { 'one': 0, 'three': 1 }
        other = h.length - 1
        rx = /\A[a-z]+(?=-)/
        a.sort_by! do | sct |
          _md = rx.match basename_ sct.path
          d = h[ _md[ 0 ] ]
          if d
            d
          else
            other += 1
          end
        end

        @freeform_state_value_x = a
        @result = nil
        NIL_
      end

      it "each structure has count (grep-style, number of matches per file)" do

        _first.count.should eql 1
        _second.count.should eql 3
      end

      it "each structure has path" do

        basename_( _first.path ).should eql _ONE_LINE_FILE
        basename_( _second.path ).should eql _THREE_LINES_FILE
      end

      it "none of the matches had zero or less" do

        _no = state_.freeform_value_x.detect do | sct |
          sct.count < 1
        end

        _no and fail
      end

      def _first
        state_.freeform_value_x.fetch 0
      end

      def _second
        state_.freeform_value_x.fetch 1
      end
    end
  end
end
