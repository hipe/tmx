require_relative '../../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] file-coverage - magnetics - CTvC - shape that is file" do

    TS_[ self ]
    use :expect_event
    use :file_coverage
    use :file_coverage_compound_tree

    it "loads" do
      compound_tree_via_classifications_magnetic_
    end

    it "of single test with counterpart" do

      against :test, :file, fixture_tree( :two, *%w( test dir-A foo-bar_spek.rb ) )

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

    # complement test :+#skipped-because-boring

    def test_dir_for_build_compound_tree
      fixture_tree_test_dir_for_ :two
    end
  end
end
