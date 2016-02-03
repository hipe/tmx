require_relative '../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] reflection - dynamic nodes example" do

    # (this is numbered 04 and not 01 to leave room for the (more important)
    # non-dynamic behavior that as yet does not have dedicated coverage.)

    TS_[ self ]
    use :memoizer_methods
    # NOTE - see #expect-no-events below
    use :expect_root_ACS

    context "fully dynamic association" do

      shared_subject :_tuple do
        _o = build_root_ACS
        st = Home_::Reflection::Node_Streamer.via_ACS( _o ).call
        _x = st.gets
        _xx = st.gets
        _xxx = st.gets and fail
        [ _x, _xx ]
      end

      context "injected association" do

        it "knowns its own category" do
          _node.category.should eql :association
        end

        it "reaches a name" do
          _node.name.as_variegated_symbol.should eql :assokie
        end

        it "reaches its association" do

          _ = _node.association.model_classifications.category_symbol
          _.should eql :primitivesque
        end

        def _node
          _tuple.fetch 0
        end
      end

      context "injected operation (perhaps useless without more hacking)" do

        it "knows its own category" do
          _node.category.should eql :operation
        end

        it "reaches a name" do
          _node.name.as_variegated_symbol.should eql :opie
        end

        it "reaches the formal (NOTE whose stack points to injector)" do
          _fo = _node.formal
          a = _fo.instance_variable_get :@selection_stack  # bad test
          a.last.name.as_variegated_symbol.should eql :opie
          _hi = a.first.ACS.hello
          _hi.should eql :_i_am_from_injector_
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
