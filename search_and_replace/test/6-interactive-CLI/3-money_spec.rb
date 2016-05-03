require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] interactive CLI integration - money" do

    TS_[ self ]
    use :my_interactive_CLI

    context "BIG KAHUNA" do

      given do

        cli do |cli|
          # comment the below line out and the changes should be written to
          # our fixture fiels (WARNING - no undo. no VCS check.)
          cli.top_frame.ACS.FILE_WRITE_IS_ENABLED = false
        end

        _dir = my_fixture_tree_ '4-egads'  # TODO must change this to be a deep copy etc..

        input(
          'ruby-regexp', "/wazoozle/i",  # makes screen 1 & 2
          'filename-patterns', EMPTY_S_,  # 3 & 4
          'paths', _dir,  # 5 & 6
          'search',  # drop into the next frame (7)
          'e', 'FANTABULOUS',  # for replacement-[e]xpression (8 & 9)
          'replace',  # creates (10)
          'n',  # [n]ext-match
          'y',  # [y]es
          'f',  # next-[f]ile
          'f',
          'a',  # [a]ll-remaining-in-file
          'w',  # [w]rite-file
        )
      end

      context "(screen)" do

        screen 10

        it "first line says filename" do

          _ = _lines.first
          _ =~ /\Afile 1 match 1 \(before\): .+some-blue\.blue\z/ or fail
        end

        it "we see one line of context before the first line with matches" do
          _lines.fetch( 1 ).include? 'if you want' or fail
        end

        it "first match of first line is highlighted" do

          _ = _lines.fetch 2
          x_a = _parse_this_line _

          x_a.first.last == '  "' or fail
          x_a[ 1 ].first == :style or fail

          _ = x_a.reduce( "" ){ |m, x| :string == x.first and m << x.last ; m }

          _ == "  \"wazoozle\" must only appear on this line, and only 2x. (\"wazoozle\")\n" or fail
        end

        shared_subject :_lines do
          __these_lines_of_interest
        end
      end

      context "(screen)" do

        screen 11

        it "says it's the second match" do
          _lines.first =~ %r(\Afile 1 match 2\b) or fail
        end

        it "the secone line is highlighted" do

          _ = _lines.fetch 2
          _x_a = _parse_this_line _
          _x_a_ = _x_a.reduce [] do |m, x|
            if :string == x.first
              m << x.last
            end
            m
          end

          _x_a_ == [
            "  \"wazoozle\" must only appear on this line, and only 2x. (\"",
            "wazoozle",
            "\")\n",
          ] or fail
        end

        shared_subject :_lines do
          _common_lines_of_interest
        end
      end

      context "(screen)" do

        screen 12

        it "says that replacement is engaged" do
          _lines.first =~ %r(\Afile 1 match 2 \(replacement engaged\)) or fail
        end

        it "having said yes to the second one, now it looks changed, colored purple" do

          x_a = _parse_this_line _lines.last
          x_a[ 1 ] == [ :style, 1, 34 ] or fail
          x_a[ -3 ].last == "FANTABULOUS" or fail
        end

        shared_subject :_lines do
          _common_lines_of_interest
        end
      end

      context "(screen) now that you moved to the next file," do

        screen 13

        it "confirms the write" do

          _lines_of_interest.first =~ %r(\Awrote file 1 \(1 replacement in 2 matches, \d+ (?:dry )?bytes\)) or fail
        end

        it "is on the next file" do

          _lines_of_interest.last =~ %r(\Afile 2 match 1 ) or fail
        end

        shared_subject :_lines_of_interest do

          st = screen.to_serr_line_stream
          a = [ st.gets ]
          _advance_past_location st
          a.push st.gets
          a
        end
      end

      context "(screen) having skipped this entre screen," do

        screen 14

        it "it says 0 replacements" do

          _ = _things.first
          _ == "file 2 (0 replacements in 1 match)" or fail
        end

        it "shows all 3 lines, styled first match is strong green" do

          a = _things.last
          a[ 0 ] == "it's time for \e[1;32mWAZOOZLE\e[0m, see\n" or fail
          a[ 1 ] == "  fazzoozle my noozle\n" or fail
          a[ 2 ] == "when i say \"wazoozle\" i mean WaZOOzle!\n" or fail
        end

        shared_subject :_things do
          _build_common_things
        end
      end

      context "(screen) having said yes to all matches in this file," do

        screen 15

        it "says N matches" do

          _ = _things.first
          _ == "3 of 3 matches engaged." or fail
        end

        it "shows all 3 lines, all replacements engaged, last one purple" do

          a = _things.last
          a[ 0 ] == "it's time for FANTABULOUS, see\n" or fail
          a[ 1 ] == "  fazzoozle my noozle\n" or fail
          a[ 2 ] == "when i say \"FANTABULOUS\" i mean \e[1;34mFANTABULOUS\e[0m!\n" or fail
        end

        shared_subject :_things do
          _build_common_things
        end
      end

      context "(screen) having said write," do

        screen 16

        it "says it wrote." do
          _lines.first =~ %r(\Awrote file 3 \(3 replacements, \d+ dry bytes\))
        end

        it "says finished and Ctrl-C" do
          _lines.last == "(job finished. Ctrl-C to jump out of frame.)"
        end

        it "says nothing more" do
          2 == _lines.length or fail
        end

        shared_subject :_lines do
          screen.to_serr_line_stream.to_a
        end
      end
    end

      # the following two lines are used by tests somewhere nearby:
      # hinkenlooper
      # hinkenlooper

    def _build_common_things

      st = screen.to_serr_line_stream
      x_a = [ st.gets ]
      _advance_past_location st
      st.gets  # skip line that declares location
      x_a.push _lines_until_blank st
      x_a
    end

    def _parse_this_line _
      Home_.lib_.brazen::CLI_Support::Styling::Parse_styles[ _ ]
    end

    def __these_lines_of_interest

      st = screen.to_serr_line_stream

      st.gets ; st.gets  # #open [#004]

      _advance_past_location st

      _lines_until_blank st
    end

    def _common_lines_of_interest
      st = screen.to_serr_line_stream
      _advance_past_location st
      _lines_until_blank st
    end

    def _advance_past_location st
      st.gets.length.zero? or fail
      st.gets == "«loco»" or fail
    end

    def _lines_until_blank st
      a = []
      begin
        s = st.gets
        s.length.zero? and break
        a.push s
        redo
      end while nil
      a
    end
  end
end
