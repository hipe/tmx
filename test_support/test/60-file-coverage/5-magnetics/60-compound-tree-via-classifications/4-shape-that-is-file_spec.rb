require_relative '../../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] file-coverage - magnetics - CTvC - shape that is file" do

    TS_[ self ]
    use :want_event
    use :file_coverage
    use :file_coverage_compound_tree

    it "loads" do
      compound_tree_via_classifications_magnetic_
    end

    it "of single test with counterpart" do

      against :test, :file, fixture_tree( :two, *%w( test dir-A foo-bar_spek.kode ) )

      _common_result
    end

    it "of single asset with counterpart" do

      against :asset, :file, "#{ fixture_tree :two }/dir-A-/foo-bar--.kode"

      _common_result
    end

    def _common_result

      nd = _common_first_level
      expect( nd.children_count ).to be_zero

      npl = nd.node_payload
      expect( npl.test_file_entry_s_a ).to eql %w( foo-bar_spek.kode )
      expect( npl.asset_file_entry_s_a ).to eql %w( foo-bar--.kode )

    end

    def _common_first_level

      nd = @tree.fetch_first_child
      expect( nd.children_count ).to eql 1

      expect( nd.slug ).to eql 'dir-A'
      expect( nd.node_payload.asset_dir_entry_s_a ).to eql %w( dir-A- )
      nd.fetch_first_child
    end

    it "of single test with no counterpart" do

      against :test, :file, "#{ fixture_tree :two }/test/dir-A/wizzie_spek.kode"

      x = @tree.fetch_only_child
      npl = x.node_payload
      expect( npl.has_tests ).to eql true
      expect( npl.has_assets ).to be_nil

      x = x.fetch_only_child
      expect( x.children_count ).to be_zero

      npl = x.node_payload
      expect( npl.test_file_entry_s_a ).to eql %w( wizzie_spek.kode )

      expect( npl.asset_dir_entry_s_a ).to be_nil

    end

    it "of single asset with no counterpart" do

      against :asset, :file, "#{ fixture_tree :two }/dir-A-/mizzie--.kode"

      x = @tree.fetch_only_child
      expect( x.slug ).to eql 'dir-A'
      npl = x.node_payload
      expect( npl.has_assets ).to eql true
      expect( npl.has_tests ).to be_nil

      x = x.fetch_only_child
      expect( x.children_count ).to be_zero
      npl = x.node_payload

      expect( npl.asset_file_entry_s_a ).to eql %w( mizzie--.kode )
    end

    it "of single test file in test directory with no counterpart" do

      against :test, :file, "#{ fixture_tree :two }/test/dir-T/hi_speg.kode"

      x = @tree.fetch_only_child

      npl = x.node_payload
      expect( npl.has_tests ).to eql true
      expect( npl.has_assets ).to be_nil

      x = x.fetch_only_child

      npl = x.node_payload
      expect( npl.has_tests ).to eql true
      expect( npl.has_assets ).to be_nil
      expect( npl.test_file_entry_s_a ).to eql %w( hi_speg.kode )

      expect( x.children_count ).to be_zero
    end

    # complement test :+#skipped-because-boring

    def test_dir_for_build_compound_tree
      fixture_tree_test_dir_for_ :two
    end
  end
end
