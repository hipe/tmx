require_relative '../../test-support'

module Skylab::SubTree::TestSupport::Models_File_Coverage

  describe "[st] models - file-coverage - 03: build compound tree - for single file" do

    extend TS_

    use :build_compound_tree

    it "of single test with counterpart" do

      against :test, :file, "#{ fixture_tree :two }/test/dir-A/foo-bar_spek.rb"

      _common_result
    end

    it "of single asset with counterpart" do

      against :asset, :file, "#{ fixture_tree :two }/dir-A-/foo-bar--.rb"

      _common_result
    end

    def _common_result

      nd = _common_first_level
      nd.children_count.should be_zero

      npl = nd.node_payload
      npl.test_file_entry_s_a.should eql %w( foo-bar_spek.rb )
      npl.asset_file_entry_s_a.should eql %w( foo-bar--.rb )

    end

    def _common_first_level

      nd = @tree.fetch_first_child
      nd.children_count.should eql 1

      nd.slug.should eql 'dir-A'
      nd.node_payload.asset_dir_entry_s_a.should eql %w( dir-A- )
      nd.fetch_first_child
    end

    it "of single test with no counterpart" do

      against :test, :file, "#{ fixture_tree :two }/test/dir-A/wizzie_spek.rb"

      x = @tree.fetch_only_child
      npl = x.node_payload
      npl.has_tests.should eql true
      npl.has_assets.should be_nil

      x = x.fetch_only_child
      x.children_count.should be_zero

      npl = x.node_payload
      npl.test_file_entry_s_a.should eql %w( wizzie_spek.rb )

      npl.asset_dir_entry_s_a.should be_nil

    end

    it "of single asset with no counterpart" do

      against :asset, :file, "#{ fixture_tree :two }/dir-A-/mizzie--.rb"

      x = @tree.fetch_only_child
      x.slug.should eql 'dir-A'
      npl = x.node_payload
      npl.has_assets.should eql true
      npl.has_tests.should be_nil

      x = x.fetch_only_child
      x.children_count.should be_zero
      npl = x.node_payload

      npl.asset_file_entry_s_a.should eql %w( mizzie--.rb )
    end

    it "of single test file in test directory with no counterpart" do

      against :test, :file, "#{ fixture_tree :two }/test/dir-T/hi_speg.rb"

      x = @tree.fetch_only_child

      npl = x.node_payload
      npl.has_tests.should eql true
      npl.has_assets.should be_nil

      x = x.fetch_only_child

      npl = x.node_payload
      npl.has_tests.should eql true
      npl.has_assets.should be_nil
      npl.test_file_entry_s_a.should eql %w( hi_speg.rb )

      x.children_count.should be_zero
    end

    # (we skip the complement test because boring)

    def test_dir_for_build_compound_tree

      Fixture_tree_test_dir_for_[ :two ]
    end
  end
end
