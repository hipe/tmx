require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] magnetics - node reference streamer via feature branch" do

    # (was: "reflection - dynamic nodes example")

    # (this is numbered 04 and not 01 to leave room for the (more important)
    # non-dynamic behavior that as yet does not have dedicated coverage.)

    TS_[ self ]
    use :memoizer_methods
    # NOTE - see #expect-no-events below
    use :want_root_ACS

    context "fully dynamic association" do

      shared_subject :_tuple do
        _o = build_root_ACS
        st = Home_::Magnetics::NodeReferenceStreamer_via_FeatureBranch.via_ACS( _o ).call
        _x = st.gets
        _xx = st.gets
        _xxx = st.gets and fail
        [ _x, _xx ]
      end

      context "injected association" do

        it "knowns its own category" do
          :association == _node.node_reference_category or fail
        end

        it "reaches a name" do
          expect( _node.name.as_variegated_symbol ).to eql :assokie
        end

        it "reaches its association" do

          _ = _node.association.model_classifications.category_symbol
          expect( _ ).to eql :primitivesque
        end

        def _node
          _tuple.fetch 0
        end
      end

      context "injected operation (perhaps useless without more hacking)" do

        it "knows its own category" do
          :operation == _node.node_reference_category or fail
        end

        it "reaches a name" do
          expect( _node.name.as_variegated_symbol ).to eql :opie
        end

        def _node
          _tuple.fetch 1
        end
      end

      def event_log  # #expect-no-events
        NIL_
      end

      def subject_root_ACS_class

        Fixture_top_ACS_class[ :Class_21_Fully_Dynamic_Nodes ]
      end
    end
  end
end
