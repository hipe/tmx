require_relative '../../test-support'

module Skylab::SubTree::TestSupport::Models_File_Coverage

  describe "[st] models - file-coverage - 03: build compound tree - for directory" do

    extend TS_

    use :build_compound_tree

    it "minimal positive case" do

      @test_dir = Fixture_tree_test_dir_for_[ :two ]

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

      npl.asset_file_entry_s_a.should eql %w( foo-bar--.rb )
      npl.test_file_entry_s_a.should eql %w( foo-bar_spek.rb )

    end

    it "level 0 test without asset is expressed" do

      _path 'twna'
      _expect_test_without_asset 'twna_speg.rb'
    end

    it "level 0 asset without test is expressed" do

      _path 'awnt'
      _expect_asset_without_test 'awnt---.rb'
    end

    it "level 1 asset without test is expressed" do

      _path 'dir-with/awnt2'
      _expect_asset_without_test 'awnt2.rb'
    end

    it "level 1 test without asset is expressed (in a folder with normal tests)" do

      _path 'aa-bb/twna2'
      _expect_test_without_asset 'twna2_speg.rb'
    end

    it "level 1 test without asset is expressed (in its own folder)" do

      _path 'dir-with-2/twna3'
      _expect_test_without_asset 'twna3_speg.rb'
    end

    it "some file are ignored per the name conventions" do

      _memoized_tree.h_.key?( 'this-file-should-be-ignored' ) and fail
    end

    it "files in two different folders get represnetation under the same node" do

      _path 'aa-bb'

      _expect_has_both @node[ 'from-one' ].node_payload
      _expect_has_both @node[ 'from-another' ].node_payload

    end

    def _path s

      @node = _memoized_tree.fetch_node s
      @npl = @node.node_payload
      NIL_
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

      @test_dir = Fixture_tree_test_dir_for_[ :three ]
      against :test, :directory, :root, @test_dir
      @tree
    end

    def _expect_asset_without_test file_entry_s

      @npl.has_assets.should eql true
      @npl.has_tests.should be_nil
      a = @npl.asset_file_entry_s_a
      a.length.should eql 1
      a.first.should eql file_entry_s
    end

    def _expect_test_without_asset file_entry_s

      @npl.has_tests.should eql true
      @npl.has_assets.should be_nil
      a = @npl.test_file_entry_s_a
      a.length.should eql 1
      a.first.should eql file_entry_s
    end

    def _expect_has_both npl

      npl.has_assets.should eql true
      npl.has_tests.should eql true
    end
  end
end
