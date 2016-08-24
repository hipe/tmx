require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] file-coverage - modalities - API" do

    TS_[ self ]
    use :expect_event
    use :file_coverage
    use :file_coverage_expect_node_characteristics

    it "no path argument - exception" do

      begin
        _call_API
      rescue ::ArgumentError => e
      end

      e.message =~ %r(\bmissing required parameter 'path') || fail
    end

    it "easy boogie against the project tree" do

      _against_path fixture_tree :one
      _common_result_for_one
    end

    it "easy boogie against the asset file" do

      _against_path fixture_tree( :one, 'foo.rb' )
      _common_result_for_one
    end

    def _common_result_for_one

      nd = @result.tree.fetch_only_child
      nd.slug == 'foo' || fail
      npl = nd.node_payload

      npl.asset_file_entry_s_a == %w( foo.rb ) || fail
      npl.test_file_entry_s_a == %w( foo_speg.rb ) || fail
    end

    it "do not boogie - noent" do

      _against_path fixture_tree( :one, 'not-there.rx' )
      expect_not_OK_event :find_error
      expect_failed
    end

    it "sub-tree under the test dir (counterparted)" do

      _against_path fixture_tree( :three, 'test', 'aa-bb' )
      _common_result_for_three

      expect_assets_and_tests_ @result.tree[ 'from-one' ]
    end

    it "sub-tree within the asset inner tree (counterparted)" do

      _against_path fixture_tree( :three, 'aa-bb--' )
      _common_result_for_three

      expect_tests_but_no_assets_ @result.tree[ 'from-one' ]
    end

    it "sub-tree within asset inner tree (no counterpart)" do

      _against_path fixture_tree( :three, 'dir-with' )

      x = @result.tree.fetch_only_child
      x.slug.should eql 'awnt2'

      expect_assets_but_no_tests_ x
    end

    # sub-tree within test dir (no counterpart) :+#skipped-because-boring

    def _common_result_for_three

      x = @result.tree

      x.children_count.should eql 3

      expect_assets_and_tests_ x[ 'from-another' ]
    end

    tfs = nil
    define_method :_against_path do |path|
      tfs ||= %w( _speg.rb )
      _call_API :path, path, :test_file_suffix, tfs
    end

    def _call_API * x_a

      x_a.unshift :file_coverage
      _oes_p = event_log.handle_event_selectively
      call_API_via_iambic x_a, & _oes_p
      NIL
    end

    def subject_API
      subsystem_::API
    end
  end
end
