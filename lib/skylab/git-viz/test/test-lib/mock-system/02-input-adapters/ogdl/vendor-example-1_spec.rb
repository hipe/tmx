require_relative 'test-support'

module Skylab::GitViz::TestSupport::Test_Lib::IA_OGDL

  describe "[gv] test-lib - mock-sys - input-adapters - OGDL - e.g's 1" do

    extend TS_

    it "vendor example 1 (1 of 5)" do

      against <<-HERE.unindent
        libraries
          foo.so
          bar.so
      HERE

      _expect_this_same_tree_stream
    end

    it "vendor example 1 (2 of 5)" do

      against <<-HERE.unindent
        libraries foo.so
          bar.so
      HERE

      _expect_this_same_tree_stream
    end

    it "vendor example 1 (3 of 5)" do

      against <<-HERE.unindent
        libraries
          foo.so, bar.so
      HERE

      _expect_this_same_tree_stream
    end

    it "vendor example 1 (4 of 5) - PARENTHESIS NOT YET IMPLEMENTED" do

      against <<-HERE.unindent
        libraries ( foo.so, bar.so )
      HERE

      begin
        @st.gets
      rescue ::NoMethodError => e
      end

      e.name.should eql :_PARENS_NOT_IMPLEMENTED
    end

    def _expect_this_same_tree_stream

      tree = @st.gets
      tree.string.should eql 'libraries'

      tree.children.length.should eql 2
      nd, nd_ = tree.children

      nd.string.should eql 'foo.so'
      nd_.string.should eql 'bar.so'

      nd.children.should be_nil
      nd_.children.should be_nil

      @st.gets.should be_nil
    end
  end
end