require_relative '../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] mode integrations - CLI - models - stow", wip: true do

    TS_[ self ]
    use :CLI

    it "list the known stows" do

      _path = ::File.join Fixture_tree_[ :filesystem_1 ], 'proggie'

      cd_ _path do
        invoke 'stow', 'list'
        want :o, "stow-1"
        want :o, "stow-2"
        want :e, "(2 stows total)"
        want_succeed
      end
    end
  end
end
