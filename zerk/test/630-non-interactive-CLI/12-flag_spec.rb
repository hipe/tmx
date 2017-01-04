require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - flag intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_expect_section_coarse_parse

    context "(the bespoke required arg)" do

      it "usage line part (is last part)" do
        _usage_line_box.a_.last == '<file>' or fail
      end

      it "there are no arguments listed at all because no descs" do
        _help_screen.section_name_symbols == [ :usage, :options ] or fail
      end

      it "came thru in the call" do  # #tB3
        'puth' == _h.fetch( :file ) or fail
      end
    end

    context "(the bespoke optional)" do

      it "usage line part" do
        _usage_h[ '[-m X]' ] or fail
      end

      it "listed and described in options" do
        _opt '-m', '--message X', 'msg'
      end

      it "came thru in the call" do  # #tB4
        _h.fetch( :M ) == "hi" or fail
      end
    end

    context "(the bespoke optional FLAG)" do

      it "usage line part" do
        _usage_h[ '[-v]' ] or fail
      end

      it "listed and described in options" do
        _opt '-v', '--verbose', 'verie'
      end

      it "came thru in the call" do  # #tB4 (flag)
        _h.fetch( :V ) == true or fail
      end
    end

    context "(the appropriated optional)" do

      it "usage line part" do
        _usage_h[ '[-d]' ] or fail
      end

      it "listed and described in options" do
        _opt '-d', '--dry-run', 'd.r'
      end

      it "came thru in the call" do  # #tB2
        _h.fetch( :D ) == true or fail
      end
    end

    context "(a non-appropriated that is in the scope set)" do

      it "usage line part" do
        _usage_h[ '[-n X]' ] or fail
      end

      it "listed and described in options" do
        _opt '-n', '--nim-nam X', 'n.n'
      end

      it "was reachable in the call" do  # !#none
        '(nn:NiNa)' == _h.fetch( :N ) or fail
      end
    end

    # -- usage line related

    def _usage_h
      _usage_line_box.h_
    end

    shared_subject :_usage_line_box do
      _x = _help_screen
      _ = _x.section( :usage ).first_line.unstyled_styled
      build_index_of_this_unstyled_usage_line _
    end

    # -- options section related

    def _opt sw, long_plus, unstyled_desc

      ___option_section_index.should have_option( sw, long_plus, unstyled_desc )
    end

    shared_subject :___option_section_index do

      build_index_of_option_section _help_screen.section :options
    end

    # -- money

    shared_subject :_h do  # (etc)

      # (this is a very ad hoc parse just for this one operation's result string)

      h = {}

      sta = argv 'fantaz', 'open', '-d', '-mhi', 'puth', '-v', '-nNiNa'

      sta.exitstatus.zero? or fail

      o_a = sta.lines

      1 == o_a.length or fail

      ( _line_content = o_a.first.string ).chomp!

      _parts = _line_content.split SPACE_  # crude

      _parts.each do |part|

        _head, _tail = part.split ':', 2
        _value_x = _tail || true
        h[ _head.intern ] = _value_x
      end

      h
    end

    # --

    shared_subject :_help_screen do
      coarse_parse_via_invoke 'fantaz', 'open', '-h'
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_41_File_Writer ]
    end
  end
end
