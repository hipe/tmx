require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - criteria - integration" do

    TS_[ self ]
    use :want_event

    context "(against alpha manifest)" do

      it "LTE and GT in a boolean expression" do

        _call_API_with_criteria %w(

            nodes that have an identifier with an integer
            less than or equal to 3
            and greater than 1 )

        st = @result
        expect( st.gets.ID.to_i ).to eql 3
        expect( st.gets.ID.to_i ).to eql 2
        expect( st.gets ).to be_nil
      end

      it "has extended content (minimal)" do

        _call_API_with_criteria %w(

          nodes that have extended content )

        st = @result
        expect( st.gets.ID.to_i ).to eql 2
        expect( st.gets ).to be_nil
      end

      it "tags! (an -OR- tree, one level deep)" do

        _call_API_with_criteria %w(

          nodes that are tagged with #open or #pazlo )

        st = @result

        expect( st.gets.ID.to_i ).to eql 5
        expect( st.gets.ID.to_i ).to eql 3
        expect( st.gets.ID.to_i ).to eql 7  # proves the lesser 'OR' branch
        expect( st.gets ).to be_nil
      end

      def _path_
        Path_alpha_[]
      end
    end

    context "(against hot rocket) many permutations of [ NOT ] ( AND | OR )" do

      it "Q and U" do

        _find %w( nodes that are tagged with #hot and #rocket )
        _expect 5, 7
      end

      it "Q or U" do

        _find %w( nodes that are tagged with #hot or #rocket )
        _expect 1, 2, 3, 4, 5, 7
      end

      it "Q and not U (see)" do

        _find %w( nodes that are tagged with #hot and are not tagged with #rocket )

        _expect 1, 3

        # the above works as is intended but it is required that the expression
        # be more verbose than we would like. the second "are" is necesssay.
        # we would like to omit any of (after the 'and') the words
        # [ are [ tagged [ with ]]]. to implement this minimally is what
        # the nascent [#005] represents.
      end

      it "Q or not U" do  # same

        _find %w( nodes that are tagged with #hot or are not tagged with #rocket )
        _expect 1, 3, 5, 6, 7, 8
      end

      # it "(EEK) not Q and U" do  # with [#005]

      # it "(EEK) not Q or U" do  # with [#005]

      def _find s_a

        _call_API_with_criteria s_a

        @d_a = @result.map_by do | node |
          node.ID.to_i
        end.to_a

        NIL_
      end

      def _expect * d_a
        expect( d_a ).to eql @d_a
      end

      def _path_
        Fixture_file_[ :hot_rocket_mani ]
      end
    end

    def _call_API_with_criteria s_a

      call_API :criteria, :issues_via_criteria, :criteria, s_a,
        :upstream_reference, _path_, & EMPTY_P_
      NIL_
    end
  end
end
