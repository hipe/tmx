require_relative '../../../../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] VCS adapters - git - models - bundle" do

    TS_[ self ]
    use :VCS_adapters_git_bundles

    it "noent - soft error" do

      bundle_against_ '/m03/repo/xx/not-there'

      start_directory_noent_
    end

    it "file - soft error" do

      bundle_against_ "/m03/repo/dirzo/it's just/funky like that"
      want_failed_by :wrong_ftype
    end

    it "dir that is not tracked - soft error" do

      bundle_against_ "/m03/repo/these-dirs/not-tracked"
      want_failed_by :directory_is_not_tracked
    end

    it "boogie boogie boogie boogie boogie" do

      bundle_against_ "/m03/repo/dirzo"

      bnch = @bundle
      expect( bnch ).to be_respond_to :ci_box
      expect( bnch.trails.length ).to eql 3
      @trail = bnch.trails.fetch 0
      __want_trail
    end

    def __want_trail

      trl = @trail
      a = trl.filechanges
      expect( a.length ).to eql 2

      bfc = a.fetch 0

      expect( bfc.SHA.string ).to eql 'fafa002000000000000000000000000000000000'
      expect( bfc.fc.insertion_count ).to eql 3
      expect( bfc.fc.deletion_count ).to be_zero

      bfc = a.fetch 1
      expect( bfc.SHA.string ).to eql 'fafa003000000000000000000000000000000000'
      expect( bfc.fc.insertion_count ).to eql 3
      expect( bfc.fc.deletion_count ).to eql 2
    end

    def manifest_path_for_stubbed_FS
      at_ :STORY_03_PATHS_
    end

    def manifest_path_for_stubbed_system
      at_ :STORY_03_COMMANDS_
    end
  end
end
