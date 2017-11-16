require_relative '../../../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] doubles - stubbed-system - input-adapters - OGDL - e.g's 2" do

    TS_[ self ]
    use :doubles_stubbed_system_OGDL

    it "vendor example 2 (1 of 5)" do

      against_ <<-HERE.unindent
        libraries
            foo.so
                version 1.2
            bar.so
                version 2.3
      HERE

      _want_this_same_tree_stream
    end

    it "vendor example 2 (2 of 5)" do

      against_ <<-HERE.unindent
        libraries
          foo.so version 1.2
          bar.so version 2.3
      HERE

      _want_this_same_tree_stream
    end

    it "vendor example 2 (4 of 5)" do

      against_ <<-HERE.unindent
        libraries
            foo.so
                version
                    1.2
            bar.so
                version
                    2.3
      HERE

      _want_this_same_tree_stream
    end

    def _want_this_same_tree_stream

      tree = @st.gets

      tree.string.should eql 'libraries'
      tree.children.length.should eql 2

      nd, nd_ = tree.children

      nd.string.should eql 'foo.so'
      nd_.string.should eql 'bar.so'

      recurse = -> do

        nd.children.length.should eql 1
        nd_.children.length.should eql 1

        nd = nd.children.fetch 0
        nd_ = nd_.children.fetch 0
      end

      recurse[]

      nd.string.should eql 'version'
      nd_.string.should eql 'version'

      recurse[]

      nd.string.should eql '1.2'
      nd_.string.should eql '2.3'

      nd.children.should be_nil
      nd_.children.should be_nil

      @st.gets.should be_nil
    end
  end
end
