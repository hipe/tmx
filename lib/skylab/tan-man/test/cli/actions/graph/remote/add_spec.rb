require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI::Actions::Graph::Remote::Add

  ::Skylab::TanMan::TestSupport::CLI::Actions::Graph::Remote[ TS_ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[ts] CLI actions graph remote add", wip: true do

    extend TS_

    it "0   - no args - custom expecting message" do
      invoke %w( g remote add )
      nonstyled_info_line.should eql( 'expecting { `script` }' )
      expect_usage_invite_result
      expect_oldschool_result_for_ui_failure
    end

    def expect_usage_invite_result
      styled_info_line.should match( USAGE_RX__ )
      expect_invite_result
    end

    def expect_invite_result
      styled_info_line.should match( INVITE_RX__ )
      expect_no_more_info_lines
    end

    INVITE_RX__ = /\Atry tanmun graph remote add -h for help\z/i

    USAGE_RX__ = /\Ausage: tanmun graph remote add \[-h\] \[node-names\] {script <script>}\z/i

    it "1.1 - one bad arg - custom complaint" do
      invoke %w( g remote add bizzle )
      nonstyled_info_line.should eql( 'expecting { `script` } at "bizzle"' )
      expect_usage_invite_result
    end

    it "1.2 - bad opt - ok" do
      invoke %w( g remote add -x )
      nonstyled_info_line.should eql( 'invalid option: -x' )
      expect_usage_invite_result
    end

    it "1.N + 1 - extra args at end" do
      invoke %w( g remote add node-names script flezo.sh bizzo )
      nonstyled_info_line.should eql( 'unexpected argument: "bizzo"' )
      expect_usage_invite_result
    end

    it "1.N.1 - well-formed request with script file not found" do
      simplified_client
      using_dotfile "(empty dotfile - content should not matter)"
      invoke_from_dotfile_dir %w( g remote add node-names script bloffo.sh )
      nonstyled_info_line.should match( %r{failed to add graph remote - #{
        }script must first exist: \./bloffo\.sh}i )
      expect_invite_result
    end

    it "1.N.3 - well-formed request when script file is found" do
      simplified_client
      using_dotfile "N/A"
      tanman_tmpdir.touch 'scripto.sh'
      invoke_from_dotfile_dir %w( g remote add node-names script scripto.sh )
      styled_info_line.should eql(
        'added attributes: "["node_names"]" with script "scripto.sh"' )
      nonstyled_info_line.should match( /updating config.+done/ )
      expect_no_more_info_lines
      @result.class.should eql( ::Fixnum )  # number of bytes
    end
  end
end
