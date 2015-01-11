require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI::Actions::Graph::Remote::Core

  ::Skylab::TanMan::TestSupport::CLI::Actions::Graph::Remote[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[ts] CLI action graph remote", wip: true do

    extend TS_

    it "1.3 - help (postfix)" do
      invoke %w( g remote -h )
      expect_help_screen
      expect_oldschool_result_for_ui_success
    end

    it "1.3 - help (prefix)" do
      invoke %w( g -h remote )
      expect_help_screen
      expect_newschool_result_for_ui_success
    end

    def expect_help_screen
      expect_section 'usage'
      expect_section 'description', :one_line, %r{\Aadd/remove/list}
      expect_section 'options' do
        expect_exactly_one_line
      end
      expect_section 'actions' do
        expect_item 'add', /adds a remote.+source.+for syncing/
        expect_item 'list', /./
        expect_item 'remove', /./
        expect_no_more_items
      end
    end
  end
end
