require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - font - list" do

    TS_[ self ]
    use :my_API

    context "you can list the fonts when the adapter is engaged (LIVE)" do

      # NOTE - if this fails try regressing to sibling test file (2)

      call_by do
        call :adapter, COMMON_ADAPTER_CONST_,
          :background_font, :list
      end

      it "result is a stream of font entities." do
        _tuple.length.should eql 2
      end

      it "the fonts can express themselves textually (as items)" do

        font = __first_font
        s = ""
        oid = s.object_id
        _ = font.express_into_under s, expression_agent_for_want_emission
        _.length.should be_nonzero
        _.object_id.should eql oid
      end

      it "the fonts are flyweighted" do

        a = _tuple
        a.fetch( 0 ).fetch( 0 ).should eql a.fetch( 1 ).fetch( 0 )
      end

      shared_subject :_tuple do

        st = root_ACS_result
        a = []
        x = st.gets
        if x
          a.push [ x.object_id, x.dup ]
        end
        x = st.gets
        if x
          a.push [ x.object_id, x ]
        end
        a
      end

      def __first_font
        _tuple.fetch( 0 ).fetch( 1 )
      end
    end
  end
end
