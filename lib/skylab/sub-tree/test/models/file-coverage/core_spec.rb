require_relative 'test-support'

module Skylab::SubTree::TestSupport::Models_File_Coverage

  describe "[st] models - file-coverage" do

    extend TS_
    use :expect_event
    use :expect_node_characteristics

    it "no path argument - exception" do

      begin
        _call_API
      rescue ::ArgumentError => e
      end

      e.message.should match %r(\Amissing required property 'path')
    end

    it "easy boogie against the project tree" do

      _against_path Fixture_tree_[ :one ]
      _common_result_for_one
    end

    it "easy boogie against the asset file" do

      _against_path ::File.join( _one, 'foo.rb' )
      _common_result_for_one
    end

    def _common_result_for_one

      nd = @result.tree.fetch_only_child
      nd.slug.should eql 'foo'
      npl = nd.node_payload

      npl.asset_file_entry_s_a.should eql %w( foo.rb )
      npl.test_file_entry_s_a.should eql %w( foo_speg.rb )
    end

    it "do not boogie - noent" do

      _against_path ::File.join( _one, 'not-there.rx' )
      expect_not_OK_event :find_error
      expect_failed
    end

    def _one
      Fixture_tree_[ :one ]
    end

    it "sub-tree under the test dir (counterparted)" do

      _against_path ::File.join( _three, 'test/aa-bb' )
      _common_result_for_three

      expect_assets_and_tests_ @result.tree[ 'from-one' ]
    end

    it "sub-tree within the asset inner tree (counterparted)" do

      _against_path ::File.join( _three, 'aa-bb--' )
      _common_result_for_three

      expect_tests_but_no_assets_ @result.tree[ 'from-one' ]
    end

    it "sub-tree within asset inner tree (no counterpart)" do

      _against_path ::File.join( _three, 'dir-with' )

      x = @result.tree.fetch_only_child
      x.slug.should eql 'awnt2'

      expect_assets_but_no_tests_ x
    end

    # sub-tree within test dir (no counterpart) :+#skipped-because-boring

    def _three

      Fixture_tree_[ :three ]
    end

    def _common_result_for_three

      x = @result.tree

      x.children_count.should eql 3

      expect_assets_and_tests_ x[ 'from-another' ]
    end

    def _against_path path

      _call_API :path, path, :test_file_suffix, %w( _speg.rb )
    end

    def _call_API * x_a

      x_a.unshift :file_coverage
      call_API_via_iambic x_a
      NIL_
    end
  end
end
