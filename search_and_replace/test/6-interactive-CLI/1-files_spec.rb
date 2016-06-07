require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] interactive CLI - files" do

    TS_[ self ]
    use :my_interactive_CLI

    context "out of the box you can get to the second screen" do

      given do
        input 's'  # [s]earch
      end

      context "first screen" do

        screen 0

        it "includes line talking bout ruby regexp none" do

          md = entity_item_table_simple_regex.match second_line
          md[1] == 'ruby-regexp' or fail
          md[2] == '(none)' or fail
        end

        it "does NOT include line talking bout grep rx", wip: true do  # #[#004]
          _screen_has_egrep_field and fail
        end
      end

      context "second screen" do

        screen 1

        it "there is NOT a buttonesque for (e.g) \"counts\"", wip: true do  # #[#004]
          buttonesques.should not_have_button_for 'counts'
        end

        it "the custom hotstring is expressed" do
          last_line.include?( 'files-by-[f]ind' ) or fail
        end
      end
    end

    context "when entered an invalid regexp" do

      given do
        input 'r', 'hi[foo'
      end

      context "second screen (after entered invalid regexp)" do

        it "says can't" do
          first_line == "premature end of char-class: /hi[foo/" or fail
        end

        it "asks again" do
          last_line == "enter ruby-regexp: " or fail
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

      it "finds three files" do
        __expect_basenames %w( one-file.txt three-file.txt four-file.txt )
      end

      it "shows find command" do
        first_line.should match %r(\Agenerated `find` command: )
      end

      # (see tombstone about omitted test because of removed feature)
    end

    # --

    context "fbg with options that don't translate to grep (#UI-could-be-improved)" do

      given do
        input(
          'r', "/h.n#{}k.nl..p.r/imx",
          'sea', 'g'
        )
      end

      it "says it couldn't" do  # #open [#006]

        lines[ 1 ] == "non convertible regexp options - 'MULTILINE', 'EXTENDED'"
        # lines[ 2 ].should match %r(\Acouldn't execute files-by-grep because )
      end
    end

    # this one string --> HINKENLOOPER <-- is part of tests in this file

    context "files by grep" do

      given do

        input(
          'r', hinkenloooper_regexp_string_,
          'p', this_test_directory_,
          'sea',
          'g'  # as in "files-by-[g]rep"
        )
      end

      context "screen that is just after having set the regex" do

        screen 2

        it "it reports that it was set" do

          first_line.should match %r(\Aset ruby regexp to /[^/]+/i\z)
        end

        it "includes line talkin bout grep rx" do
          _screen_has_egrep_field or fail
        end
      end

      context "third screen (after having pressed `search`)" do

        screen 3

        it "there IS a buttonesque for (e.g) counts" do
          buttonesques.should have_button_for 'counts'
        end
      end

      context "last screen" do

        it "results in two files" do  # #open [#006]

          a = lines
          a[ 2 ].include? 'files_spec' or fail
          a[ 3 ].include? 'money_spec' or fail
          a[ 4 ].length.zero? or fail
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

    def __expect_basenames a

      st = screen.to_content_line_stream_on :serr
      st.gets  # #open [#006] (only one for find. none for other)
      a_ = []
      begin
        s = st.gets
        s.length.zero? and break
        a_.push ::File.basename s
        redo
      end while nil

      extra = a_ - a
      missing = a - a_

      if extra.length.nonzero?
        fail "extra: #{ extra.inspect }"
      end

      if missing.length.nonzero?
        fail "missing: #{ missing.inspect }"
      end
    end

    # :#open [#006] marks nasty hard-coded expectation of a certain number
    # (1 or 2) of debugging lines before the main content lines
  end
end
# #tombstone: expression of number of items was lost near [#ze-022]
