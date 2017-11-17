require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - sing-plur intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_want_section_coarse_parse

    context "singplur in opts - help" do

      given_screen do
        argv 'no-args', '-h'
      end

      it "usage line has option" do
        _ULI.has_key( '[-f X]' ) or fail
      end

      it "no args" do
        _ = _ULI.at_offset( -1 )
        _[ 0 ] == '[' or fail
      end

      shared_subject :_ULI do
        build_index_of_first_usage_line
      end

      it "option" do
        build_index_of_option_section.should have_option( '-f', '--foobizzle X' )
      end
    end

    context "singplur in opts - some calls" do

      it "call with none" do
        argv( 'no-args' ).should output "(yasure: nil)"
      end

      it "call with one" do
        argv( 'no-args', '-f', 'x1' ).should output '(yasure: ["x1"])'
      end

      it "call with two" do
        _output_this = output '(yasure: ["x1", "x2"])'
        argv( 'no-a', '-f', 'x1', '-f', 'x2' ).should _output_this
      end
    end

    context "plur as arg - help" do

      given_screen do
        argv 'plur-as-arg', '-h'
      end

      it "usage line looks right" do
        _ = section( :usage ).raw_line 0
        _.string[ 35..-2 ] == "<foobizzle> [<foobizzle> [..]]" or fail
      end

      it "no options" do
        section( :option ).line_count == 2 or fail
      end
    end

    context "plur as args - some calls" do

      it "zero args - missing required argument!" do
        sta = argv 'plur-as-arg'
        sta.exitstatus.nonzero? or fail
        sta.lines.first.should be_line( :styled, :e, /\Amissing required argument <foobizzle>/ )
      end

      it "one arg" do
        argv( 'plur-as-arg', 'one' ).should output '(youbetcha: ["one"])'
      end

      it "two args" do
        argv( 'plur-as-arg', 'one', 'two' ).should output '(youbetcha: ["one", "two"])'
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_14_Sing_Plur_Intro ]
    end
  end
end
