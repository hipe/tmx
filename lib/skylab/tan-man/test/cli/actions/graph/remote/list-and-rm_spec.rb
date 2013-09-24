require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI::Actions::Graph::Remote::List__

  ::Skylab::TanMan::TestSupport::CLI::Actions::Graph::Remote[ TS__ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[ts] CLI actions graph remote list, remove" do

    extend TS__

    it "N.X ( no local config file ) - whines" do
      simplified_client
      clear_and_prepare
      @dotfile_pathname = tanman_tmpdir.join( 'jeepers.dot' )
      invoke_from_dotfile_dir %w( g remote list )
      nonstyled_info_line.should match( /couldn't find.+or any parent/ )
      styled_info_line.should match( /\A\w+ tanmun init to create it/i )
      expect_no_more_lines
      expect_oldschool_result_for_ui_failure
    end

    it "N ( good local config file ) - renders table" do
      with_config_file_with_some_remotes
      invoke_from_dotfile_dir %w( g remote list )
      nonstyled_pay_line.
        should match( /\A\| +Remote type \| +Locator \| +Attributes \|\z/ )
      nonstyled_pay_line.should match( /.+script.+oiseau\.sh.+node_names/ )
      nonstyled_pay_line.should match( /.+script.+tori\.sh \| +\|\z/ )
      nonstyled_info_line.should eql( '2 remotes total.' )
      expect_no_more_lines
      expect_newschool_result_for_success
    end

    def with_config_file_with_some_remotes
      simplified_client
      using_config <<-HERE.unindent
        using_dotfile = jeepers.dot
        ["jeepers.dot" remote script "oiseau.sh"]
        attributes = ["node_names"]
        ["nopers.dot" remote script "fiffle.sh"]
        ["jeepers.dot" remote script "tori.sh"]
        attributes = []
      HERE
      @dotfile_pathname = tanman_tmpdir.touch 'jeepers.dot'
      nil
    end

    it "N.X ( script not found ) - whines" do
      with_config_file_with_some_remotes
      invoke_from_dotfile_dir %w( g remote remove fandango.sh )
      nonstyled_info_line.should match( /failed to remove.+#{
        }"fandango\.sh" was not found among 2 remotes/ )
      styled_info_line.
        should match( /\A\w+ tanmun graph remote remove -h for help/ )
      expect_no_more_lines
      expect_oldschool_result_for_ui_failure
    end

    it "N ( specify a good script ) - removes" do
      with_config_file_with_some_remotes
      invoke_from_dotfile_dir %w( g remote remove tori.sh )
      nonstyled_info_line.should match( /while.+removing.+removed section.+tori/ )
      nonstyled_info_line.should match( /updating.+done/ )
      expect_no_more_lines
      @result.should be_kind_of( ::Fixnum )
      scn = api.invoke( [ :graph, :remote, :list ] ).result  # TanMan::API.debug!
      a = scn.to_a
      a.length.should eql( 1 )
      a[ 0 ].entity_key.should eql( '"jeepers.dot" remote script "oiseau.sh"' )
    end
  end
end
