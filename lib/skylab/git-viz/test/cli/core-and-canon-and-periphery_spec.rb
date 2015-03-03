require_relative 'test-support'

module Skylab::GitViz::TestSupport::CLI

  describe "[gv] CLI - core and canon and periphery" do

    extend TS__ ; use :expect

    it "loads" do
      GitViz_::CLI
    end

    it "builds a client (manually)" do
      GitViz_::CLI::Client.new nil, nil, nil
    end

    it "builds a client (canonically)" do
      client && @client or fail "client?"
    end

    it "0   invoke with no args - e/u/i" do
      invoke
      expect_expecting_line_with_action_subset :ping, :hist_tree
      expect_usaged_and_invited
    end

    it "1.1 invoke with strange arg - w/e/i" do
      invoke 'strange'
      expect_whine_about_invalid_action :strange
      expect_expecting_and_invited
    end

    it "1.2 invoke with strange option - SAME (b.c legacy)" do
      invoke '-x'
      expect_whine_about_invalid_action '-x'
      expect_expecting_and_invited
    end

    def expect_whine_about_invalid_action x
      _rx = %r(\Ainvalid action:? ['"]?#{ ::Regexp.escape x }['"]?\z)i
      expect :styled, _rx ; nil
    end

    def expect_expecting_and_invited
      expect_expecting_line
      expect_invited ; nil
    end
  end
end
