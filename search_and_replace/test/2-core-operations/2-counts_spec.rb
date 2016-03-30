require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] core operations - counts" do

    TS_[ self ]
    use :my_API

    context 'normal case' do

      call_by do

        state = call(
          :ruby_regexp, /[ ]/,
          :path, common_haystack_directory_,
          :filename_patterns, EMPTY_A_,
          :search,
          :counts,
        )

        a = state.result  # see next method (normally it's a stream)

        # eek sort of normalize the result we get back from `find` in a way
        # that hopefully won't break when files are added in the future ..

        h = { 'one' => 0, 'three' => 1 }
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

        state.to_state_with_customized_result a
      end

      def root_ACS_state_via result, acs

        # kinda nasty - because the "summary" event doesn't fire until once
        # we exhaust the stream, and we can't emit any events once the event
        # log has closed, then we must exhaust the stream before the event
        # log closes. so we exhaust the stream by flushing it to an array
        # before the "expect event" library closes the log & makes the state.

        super result.to_a, acs
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

        _no = root_ACS_customized_result.detect do |sct|
          sct.count < 1
        end

        _no and fail
      end

      def _first
        root_ACS_customized_result.fetch 0
      end

      def _second
        root_ACS_customized_result.fetch 1
      end
    end
  end
end
