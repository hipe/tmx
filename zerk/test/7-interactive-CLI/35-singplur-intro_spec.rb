require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] iCLI - singplur intro" do

    # call this (mandatory) #mode-tweaking if you like. in the entity-item view
    # view it never makes sense to express the singluar counterpart of
    # a sing-plur pairing. always render the plural counterpart only.
    #
    # (because the plural can express everything the singular can but the
    # reverse it not true, and for consistency we should only use one.)

    TS_[ self ]
    use :memoizer_methods
    use :expect_screens

    given do
      common_compound_frame_for_design_
      input 'f', 'doozie poozie', 'no-args', 'plur-as-arg'
    end

    context "(first screen)" do

      screen 0

      it "has button for the plural but not the singluar" do

        o = buttonesques
        o.should have_button_for 'foobizzles'
        o.should not_have_button_for 'foobizzle'
      end

      it "only 'foobizzles' appears in the entity-item table" do

        h = _this_index
        h[ 'foobizzles' ] or fail
        h[ 'foobizzle' ] and fail
      end

      it "this listy slot says (none)" do

        _this_index[ 'foobizzles' ] == '(none)' or fail
      end

      shared_subject :_this_index do  # ..
        __build_this_index
      end
    end

    context "(next screen)" do

      screen 1

      it "explains the thing with lists (first line singular)" do

        first_line == "multiple foobizzles can be expressed by separating them with spaces." or fail
      end

      it "explains the thing with lists (second line plural)" do

        second_line == "certain characters will require that the foobizzle use quotes and backslashes." or fail
      end
    end

    context "(next screen)" do

      screen 2

      it "echos what you entered in the platformy way (ick/meh)" do

        first_line == 'set foobizzles to ["doozie", "poozie"]' or fail
      end

      it "now the screen shows the items in the entity-item table" do

        _md = entity_item_table_simple_regex.match screen.serr_lines.fetch 3
        _md[ 2 ] == "doozie, poozie" or fail
      end
    end

    context "(next screen)" do

      screen 3

      it "the one operation worked" do

        screen.first_line_content == '(yasure: ["doozie", "poozie"])' or fail
      end
    end

    context "(next screen)" do

      screen 4

      it "the other operation worked" do

        screen.first_line_content == '(youbetcha: ["doozie", "poozie"])' or fail
      end
    end

    def __build_this_index
      h = {}
      rx = entity_item_table_simple_regex
      st = screen.to_content_line_stream_on :serr
      st.gets  # (location..)
      begin
        s = st.gets
        s or break
        s.length.zero? and break
        md = rx.match s
        h[ md[ 1 ] ] = md[ 2 ]
        redo
      end while nil
      h
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_14_Sing_Plur_Intro ]
    end
  end
end
