require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] algorithm - \"discrete spillover\"" do

    TS_[ self ]
    use :memoizer_methods

    context "synopsis" do

      shared_subject :me do
        Home_::Algorithm::DiscreteStream_via_NumeratorStream_and_DiscretePool_and_Denominator
      end

      it "so, half of six is three, right? so" do

        expect( ( me.shortcut( [0.5, 0.5], 6 ).to_a ) ).to eql [ 3, 3 ]
      end

      it "let's break up 12 (\"pixels\") with this stream of ratios" do

        st = me.shortcut [0.25, 0.334, 1.0/6], 12

          # one quarter of 12 is 3:
        expect( st.gets ).to eql 3

          # one third of 12 is 4:
        expect( st.gets ).to eql 4

          # one sixth of 12 is 2:
        expect( st.gets ).to eql 2

          # all done
        expect( st.gets ).to eql nil
      end

      it "accumulated amount of spillover reaches 1" do

        one_seventh = 1.0/7

        st = me.shortcut [one_seventh, one_seventh, one_seventh], 10

          # one seventh of 10 is about 1.4285..
        expect( st.gets ).to eql 1

          # again, there is 0.4285.. of "spillover"
        expect( st.gets ).to eql 1

          # because the total "spillover" has reached 1, pop!
        expect( st.gets ).to eql 2
      end
    end
  end
end
# #tombstone: fully re-conceived as a "pure" function from what used to be "lipstick"
