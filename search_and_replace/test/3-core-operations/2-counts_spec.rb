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

        indexes = []
        scores = []
        a.each_with_index do |sct, idx|
          md = rx.match basename_ sct.path
          md or next
          indexes.push idx
          scores[ idx ] = h[ md[ 0 ] ] || ( other += 1 )
        end

        indexes.sort_by! do |idx|
          scores.fetch idx
        end

        _a_ = indexes.map do |idx|
          a.fetch idx
        end

        state.to_state_with_customized_result _a_
      end

      def root_ACS_state_via result, acs

        # kinda nasty - because the "summary" event doesn't fire until once
        # we exhaust the stream, and we can't emit any events once the event
        # log has closed, then we must exhaust the stream before the event
        # log closes. so we exhaust the stream by flushing it to an array
        # before the "want event" library closes the log & makes the state.

        super result.to_a, acs
      end

      it "each structure has count (grep-style, number of matches per file)" do

        expect( _first.count ).to eql 1
        expect( _second.count ).to eql 3
      end

      it "each structure has path" do

        expect( basename_( _first.path ) ).to eql _ONE_LINE_FILE
        expect( basename_( _second.path ) ).to eql _THREE_LINES_FILE
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
