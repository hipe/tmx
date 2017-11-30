require_relative '../../../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] doubles - stubbed-system - input-adapters - OGDL - e.g's 1" do

    TS_[ self ]
    use :doubles_stubbed_system_OGDL

    it "vendor example 1 (1 of 5)" do

      against_ <<-HERE.unindent
        libraries
          foo.so
          bar.so
      HERE

      _want_this_same_tree_stream
    end

    it "vendor example 1 (2 of 5)" do

      against_ <<-HERE.unindent
        libraries foo.so
          bar.so
      HERE

      _want_this_same_tree_stream
    end

    it "vendor example 1 (3 of 5)" do

      against_ <<-HERE.unindent
        libraries
          foo.so, bar.so
      HERE

      _want_this_same_tree_stream
    end

    it "vendor example 1 (4 of 5) - PARENTHESIS NOT YET IMPLEMENTED" do

      against_ <<-HERE.unindent
        libraries ( foo.so, bar.so )
      HERE

      begin
        @st.gets
      rescue ::NoMethodError => e
      end

      expect( e.name ).to eql :_PARENS_NOT_IMPLEMENTED
    end

    def _want_this_same_tree_stream

      tree = @st.gets
      expect( tree.string ).to eql 'libraries'

      expect( tree.children.length ).to eql 2
      nd, nd_ = tree.children

      expect( nd.string ).to eql 'foo.so'
      expect( nd_.string ).to eql 'bar.so'

      expect( nd.children ).to be_nil
      expect( nd_.children ).to be_nil

      expect( @st.gets ).to be_nil
    end
  end
end
