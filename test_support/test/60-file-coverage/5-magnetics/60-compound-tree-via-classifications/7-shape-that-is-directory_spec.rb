require_relative '../../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] file-coverage - magnetics - CTvC - shape that is directory" do

    TS_[ self ]
    use :want_event
    use :file_coverage
    use :file_coverage_compound_tree
    use :file_coverage_want_node_characteristics

    it "minimal positive case" do

      @test_dir = fixture_tree_test_dir_for_ :two

      against :test, :directory, :root, @test_dir

      x = @tree.fetch_only_child
      x.slug.should eql 'dir-A'  # normal
      npl = x.node_payload

      npl.has_assets.should eql true
      npl.has_tests.should eql true

      npl.asset_dir_entry_s_a.should eql %w( dir-A- )
      npl.test_dir_entry_s_a.should eql %w( dir-A )

      x = x.fetch_only_child
      x.is_leaf.should eql true

      x.slug.should eql 'foo-bar'  # normal

      npl = x.node_payload
      npl.has_assets.should eql true
      npl.has_tests.should eql true

      npl.asset_file_entry_s_a.should eql %w( foo-bar--.kode )
      npl.test_file_entry_s_a.should eql %w( foo-bar_spek.kode )

    end

    it "level 0 test without asset is expressed" do

      _path 'twna'
      _want_test_without_asset 'twna_speg.kode'
    end

    it "level 0 asset without test is expressed" do

      _path 'awnt'
      _want_asset_without_test 'awnt---.kode'
    end

    it "level 1 asset without test is expressed" do

      _path 'dir-with/awnt2'
      _want_asset_without_test 'awnt2.kode'
    end

    it "level 1 test without asset is expressed (in a folder with normal tests)" do

      _path 'aa-bb/twna2'
      _want_test_without_asset 'twna2_speg.kode'
    end

    it "level 1 test without asset is expressed (in its own folder)" do

      _path 'dir-with-2/twna3'
      _want_test_without_asset 'twna3_speg.kode'
    end

    it "some file are ignored per the name conventions" do

      _memoized_tree.h_.key?( 'this-file-should-be-ignored' ) and fail
    end

    it "files in two different folders get represnetation under the same node" do

      _path 'aa-bb'

      want_assets_and_tests_ @node[ 'from-one' ]
      want_assets_and_tests_ @node[ 'from-another' ]
    end

    def _path s

      @node = _memoized_tree.fetch_node s
      NIL
    end

    define_method :_memoized_tree, -> do
      p = nil
      -> do
        if p
          p[]
        else
          x = __build_memoized_tree
          p = -> { x }
          x
        end
      end
    end.call

    def __build_memoized_tree

      @test_dir = fixture_tree_test_dir_for_ :three
      against :test, :directory, :root, @test_dir
      @tree
    end

    def _want_asset_without_test file_entry_s

      want_assets_but_no_tests_ @node

      a = @node.node_payload.asset_file_entry_s_a
      a.length.should eql 1
      a.first.should eql file_entry_s
    end

    def _want_test_without_asset file_entry_s

      want_tests_but_no_assets_ @node

      a = @node.node_payload.test_file_entry_s_a
      a.length.should eql 1
      a.first.should eql file_entry_s
    end
  end
end
