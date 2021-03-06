require_relative '../../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node collection - expads - f.s - extended content" do

    TS_[ self ]
    use :want_event

    context "in a manifest with a corresponding directory" do

      it "one that has has" do

        # #lends-coverage to [#fi-008.11]

        call_API :node, :to_stream,
          :identifier, 2,
          :upstream_reference, _path, & EMPTY_P_

        expect( @result.has_extended_content ).to eql true
      end

      it "one that has not has not" do

        call_API :node, :to_stream,
          :identifier, 5,
          :upstream_reference, _path, & EMPTY_P_

        expect( @result.has_extended_content ).to eql false
      end

      def _path
        Path_alpha_[]
      end
    end

    # it "a brand new node.."
  end
end
