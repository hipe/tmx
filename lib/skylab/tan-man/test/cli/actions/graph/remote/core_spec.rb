require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI::Actions::Graph::Remote::Core

  ::Skylab::TanMan::TestSupport::CLI::Actions::Graph::Remote[ TS__ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[ts]" do

    extend TS__

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
      expect_section 'action' do
        expect_item 'add', /adds a remote.+source.+for syncing/
        expect_no_more_items
      end
    end
  end
end
