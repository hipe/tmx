require_relative '../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] modality integrations - CLI" do

    extend TS_
    use :my_CLI_expectations

    define_method :expect, instance_method( :expect )  # because rspec

    it "0   invoke with no args - e/u/i" do
      invoke
      expect_generic_expecting_line
      expect_usaged_and_invited
    end

    it "1.1 invoke with strange arg - w/e/i" do
      invoke 'strange'
      expect_unrecognized_action :strange
      expect_express_all_known_actions
      expect_generically_invited
    end

    it "1.2 invoke with strange option - SAME (b.c legacy)" do
      invoke '-x'
      expect_whine_about_unrecognized_option '-x'
      expect_generically_invited
    end

    _HELLO = 'hello from git viz.'.freeze

    it "1.3 just a simple ping" do
      invoke 'ping'
      expect :e, _HELLO
      expect_no_more_lines
      @exitstatus.should eql :hello_from_git_viz
    end

    it "1.4 helf" do
      invoke '-h'
      ( 9 .. 9 ).should be_include count_contiguous_lines_on_stream( :e )
      expect_no_more_lines
      @exitstatus.should be_zero
    end

    it "N   ping with an option to use the pay channel" do
      invoke 'ping', '--on-channel', 'payload'
      expect :o, _HELLO
      expect_no_more_lines
      @exitstatus.should eql :hello_from_git_viz
    end
  end
end
