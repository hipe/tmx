require_relative '../../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] mode integrations - CLI - models - stow" do

    extend TS_
    use :modality_integrations_CLI_support

    it "list the known stows" do

      _path = ::File.join Fixture_tree_[ :filesystem_1 ], 'proggie'

      cd_ _path do
        invoke 'stow', 'list'
        expect :o, "stow-1"
        expect :o, "stow-2"
        expect :e, "(2 stows total)"
        expect_succeeded
      end
    end
  end
end
