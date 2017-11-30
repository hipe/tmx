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

      expect( tree.string ).to eql 'libraries'
      expect( tree.children.length ).to eql 2

      nd, nd_ = tree.children

      expect( nd.string ).to eql 'foo.so'
      expect( nd_.string ).to eql 'bar.so'

      recurse = -> do

        expect( nd.children.length ).to eql 1
        expect( nd_.children.length ).to eql 1

        nd = nd.children.fetch 0
        nd_ = nd_.children.fetch 0
      end

      recurse[]

      expect( nd.string ).to eql 'version'
      expect( nd_.string ).to eql 'version'

      recurse[]

      expect( nd.string ).to eql '1.2'
      expect( nd_.string ).to eql '2.3'

      expect( nd.children ).to be_nil
      expect( nd_.children ).to be_nil

      expect( @st.gets ).to be_nil
    end
  end
end
