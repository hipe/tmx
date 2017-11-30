require_relative '../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] CLI - intro" do

    TS_[ self ]
    use :my_CLI

    it "0   invoke with no args - e/u/i" do
      invoke
      want_expecting_action_line
      want_usaged_and_invited
    end

    it "1.1 invoke with strange arg - w/e/i" do
      invoke 'strange'
      want_unrecognized_action :strange
      want_express_all_known_actions
      want_generically_invited
    end

    it "1.2 invoke with strange option - SAME (b.c legacy)" do
      invoke '-x'
      want_whine_about_unrecognized_option '-x'
      want_generically_invited
    end

    _HELLO = 'hello from git viz.'.freeze

    it "1.3 just a simple ping" do
      invoke 'ping'
      want :e, _HELLO
      want_no_more_lines
      expect( @exitstatus ).to eql :hello_from_git_viz
    end

    it "1.4 helf" do
      invoke '-h'
      expect( 9 .. 9 ).to be_include count_contiguous_lines_on_stream( :e )
      want_no_more_lines
      expect( @exitstatus ).to be_zero
    end

    it "N   ping with an option to use the pay channel" do
      invoke 'ping', '--on-channel', 'payload'
      want :o, _HELLO
      want_no_more_lines
      expect( @exitstatus ).to eql :hello_from_git_viz
    end
  end
end
