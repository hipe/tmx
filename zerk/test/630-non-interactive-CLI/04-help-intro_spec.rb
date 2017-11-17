require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - help intro" do  # (was in [ac])

    TS_[ self ]
    use :memoizer_methods
    use :CLI_want_section_coarse_parse

    it "1.4)   topmost help screen shows desc of op that is in frame 1" do

      _rx = %r(^ +wazoozie-foozie +have fun\n)
      _top_help_screen.section( :actions ).should have_styled_line_matching _rx
    end

    context "2.0)   missing a required argument" do

      given do
        argv 'waz'
      end

      it "fails" do
        fails
      end

      it "whines in a modality-customized way (says \"argument\" not etc)" do

        _s = "missing required argument <flim-flam>"

        first_line.should be_line( :styled, :e, _s )
      end

      it "invite" do

        second_line.should be_invite_with_argument_focus
      end
    end

    context "2.3)   with both required args" do

      given do
        argv 'waz', 'yiz', 'ziz'
      end

      it "succeeds" do
        succeeds
      end

      it "one styled stderr line (1 req'd besoke, 1 req'd app'd)" do
        first_line.should be_line( :styled, :e, "hello yiz (nn:ziz)" )
      end

      it "the result is written to stdout (covers ints as results)" do
        last_line.should be_line( :o, '12332' )
      end
    end

    context "2.4) help screen for operation, option postfixed" do

      given_screen do
        argv 'waz', '-h'
      end

      it "succeeds" do
        succeeds
      end

      it "the first words of the usage line look right" do

        bx = _usage_index
        bx.at_offset( 1 ) == 'xyzi' or fail
        bx.at_offset( 2 ) == 'wazoozie-foozie' or fail
      end

      it "usage section is only one line long" do

        2 == section( :usage ).line_count or fail  # (one for the blank line)
      end

      it "the option appears in the usage section (eek jumps ahead to flags)" do

        _usage_index[ '[-d]' ] or fail
      end

      it "the bespoke required parameter appears in the usage section" do

        _usage_index[ '<flim-flam>' ] or fail
      end

      it "the appropriated required parameter appears in the usage section" do

        _usage_index[ '<nim-nam>' ] or fail
      end

      it "description section is styled, has content" do

        section( :description ).should be_description_line_of( :styled, "have fun" )
      end

      it "the arguments section speaks of the bespoke parameter" do

        _li = section( :arguments ).line_at_offset 1
        _li.should be_item_pair( :styled, 'flim-flam', "f.f" )
      end

      it "the arguments section speaks of the appropriated parameter" do

        _li = section( :arguments ).line_at_offset 2
        _li.should be_item_pair( :styled, 'nim-nam', "n.n" )
      end

      dangerous_memoize :_usage_index do

        build_index_of_first_usage_line
      end
    end

    it "1.4.B) first help screen shows classic desc of asc in frame 1" do

      _rx = %r(^[ ]{2,}fantazzle-dazzle[ ]{2,}yay$)
      _top_help_screen.section( :actions ).should have_styled_line_matching _rx
    end

    it "1.4.C) first help screen shows classic desc of frame 1 itself" do

      _rx = %r(\bwrites files\b)
      _ = _top_help_screen.section( :description ).first_line.unstyled_styled
      _ =~ _rx or fail
    end

    dangerous_memoize :_top_help_screen do

      coarse_parse_via_invoke '-h'
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_41_File_Writer ]
    end
  end
end
