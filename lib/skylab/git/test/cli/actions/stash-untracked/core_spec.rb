require_relative 'test-support'

module Skylab::Git::TestSupport::CLI::Actions::Stash_Untracked::Core__

  ::Skylab::Git::TestSupport::CLI::Actions::Stash_Untracked[ TS__ = self ]

  include CONSTANTS

  OUT_I = OUT_I ; ERR_I = ERR_I

  extend TestSupport_::Quickie

  describe "[gi] CLI gsu core" do

    extend TS__

    it "CLI client loads" do  # can be moved up when appropriate
      Git_::CLI::Client
    end

    it "CLI box action loads" do
      Git_::CLI::Actions::Stash_Untracked
    end

    it "ping CLI payload line" do
      invoke 'ping', 'foo'
      expect OUT_I, '(foo)'
      expect_pinged_from_CLI
    end

    it "ping CLI info line" do
      invoke 'ping', 'fiz', 'faz'
      expect ERR_I, '(fiz, faz)'
      expect_pinged_from_CLI
    end

    it "ping CLI error line" do
      invoke 'ping', 'wrong'
      expect ERR_I, 'this was wrong: "wrong"'
      expect_pinged_from_CLI
    end

    def expect_pinged_from_CLI
      expect_no_more_lines
      @result.should eql :ping_from_GSU
    end

    it "ping API payload line" do
      invoke 'ping', '--API', * necessary_opts, 'zerf'
      expect OUT_I, '(out:zerf)'
      expect_pinged_from_API
    end

    it "ping API info and error, with styling" do
      invoke 'ping', '--API', * necessary_opts, 'zeek', 'zack'
      expect :nonstyled, ERR_I, "(while pinging stash(es), zeek)"
      expect :styled, ERR_I, /\A\(failed to ping stash\(es\) - pretending #{
        }this was wrong: zack\)\z/
      expect_pinged_from_API
    end

    def necessary_opts
      [ '--stashes', gsu_tmpdir.to_s ]
    end

    def expect_pinged_from_API
      expect_no_more_lines
      @result.should eql :pingback_from_API
    end
  end
end
