require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] interactive CLI integration - files", wip: true do

    TS_[ self ]
    use :expect_screens
    use :interactive_CLI

    context "out of the box you can get to the second screen" do

      given do
        input 'sea'
      end

      context "first screen" do

        it "includes line talking bout ruby regexp none" do

          _x = lines
          _x.detect( & /\A[ ]+ruby-regexp[ ]+\(none\)\z/.method( :=~ ) ) or fail
        end

        it "does NOT include line talking bout grep rx" do
          _screen_has_egrep_field and fail
        end

        def screen
          first_screen
        end
      end

      context "second screen" do

        it "there is NOT a buttonesque for (e.g) \"counts\"" do
          buttonesques.should not_have_button_for 'counts'
        end

        it "the custom hotstring is expressed" do
          last_line.should be_include 'files-by-[f]ind'
        end
      end
    end

    context "when entered an invalid regexp" do

      given do
        input(
          'r', 'hi[foo',
        )
      end

      context "second screen (after entered invalid regexp)" do

        it "says can't" do
          first_line.should eql "premature end of char-class: /hi[foo/"
        end

        it "asks again" do
          last_line.should eql "enter ruby-regexp: "
        end
      end
    end

    # --

    context "files by find (note no regexp entered)" do

      given do

        _dir = __dir_of_some_depth

        input(
          'p', _dir,
          'f', EMPTY_S_,  # (all files)
          'se', 'f',
        )
      end

      it "writes to SOUT" do
        __expect_basenames %w( one-file.txt three-file.txt four-file.txt )
      end

      it "shows find command" do
        first_line.should match %r(\Agenerated `find` command: )
      end

      it "says how many items found" do
        second_line.should match %r(\A\(3 strings total\)\z)
      end

      def lines
        screen.serr_lines
      end
    end

    # --

    context "fbg with options that don't translate to grep (#UI-could-be-improved)" do

      given do
        input(
          'r', "/h.n#{}k.nl..p.r/imx",
          'sea', 'g'
        )
      end

      it "says it couldn't" do
        lines[ 2 ].should match %r(\Acouldn't execute files-by-grep because )
      end
    end

    # this one string --> HINKENLOOPER <-- is part of tests in this file

    context "files by grep" do

      given do

        input(
          'r', hinkenloooper_regexp_string_,
          'p', this_directory_that_exists_,
          'sea',
          'g'  # as in "files-by-[g]rep"
        )
      end

      context "screen that is just after having set the regex" do

        it "it reports that it was set" do

          first_line.should match %r(\Aset ruby regexp to /[^/]+/i\z)
        end

        it "includes line talkin bout grep rx" do
          _screen_has_egrep_field or fail
        end

        def screen
          screens.fetch 2
        end
      end

      context "third screen (after having pressed `search`)" do

        it "there IS a buttonesque for (e.g) counts" do
          buttonesques.should have_button_for 'counts'
        end

        def screen
          screens.fetch 3
        end
      end

      context "last screen" do

        it "results in two files" do
          screen.count_lines_on( :sout ).should eql 2
        end

        it "ends with buttons of the correct frame" do
          is_on_frame_number_with_buttons_ 2
        end
      end
    end

    # --

    # ~ setup

    def __dir_of_some_depth
      TestSupport_::Fixtures.dir :some_depth
    end

    # ~ assertion

    _EGREP_LABEL = 'egrep-pattern'
    define_method :_screen_has_egrep_field do
      lines.each.detect do | l |
        l.include? _EGREP_LABEL
      end
    end

    def __expect_basenames a  # mutates argument

      # for when every STDOUT line (on the particular screen) is a path,
      # assert that the set formed by the basenames of those paths is exactly
      # the set expressed by the argument array. (order doesn't matter.)
      # (undefined for the case of multiple lines with the same basename.)

      screen.to_content_line_stream_on( :sout ).map_by do |s|
        s = ::File.basename s
        d = a.index s
        d or fail
        a[ d ] = nil
        true
      end.flush_to_last

      a.compact!
      a.length.zero? or fail
    end
  end
end
