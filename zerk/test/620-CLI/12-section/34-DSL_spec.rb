require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI - section - DSL" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_section_DSL

    context "(long story)" do

      shared_subject :_state do

        # currently this serves as the only documentation for [#061.2].
        # reviewing [#br-002]/figure-3 will assist in understanding the
        # conceptual document structure.
        #
        # look at the below `yield_` calls and image they are real yields.
        # the `section` directive demarcates where one section ends and
        # another begins..

        sta = _My_State.new

        invex = begin_invex_ sta

        @subject = subject_class_.new invex

        yield_ :allow_item_descriptions_to_have_N_lines, 3

        yield_ :section, :name_symbol, :bone

        yield_( :item,
          :moniker_proc, moniker_( :femur ),
          :descriptor, desc_( :femur, 1 ),
        )

        invex._at_this_point_ :_nothing_will_have_been_emitted

        yield_ :section, :name_symbol, :organ

        invex._at_this_point_ :_the_previus_section_will_have_been_emitted

        yield_( :item,
          :moniker_proc, moniker_( :pancreas ),
          :descriptor, desc_( :pancreas, 4 ),
        )

        yield_( :item,
          :moniker_proc, moniker_( :liver ),
          :descriptor, desc_( :liver, 3 ),
        )

        _x = @subject.finish

        _cls = TS_::CLI::Expect_Section_Coarse_Parse

        sta.screen = _cls.new sta.lines

        sta.result = _x

        sta
      end

      it "loads" do
        subject_class_
      end

      it "there are 2 sections" do

        _scr = _screen
        2 == _scr.section_count or fail
      end

      it "the second section has 2 items, each with more than 2 lines of desc" do

        items = _second_section.items
        items.length == 2 or fail
        items[0].body_lines.length > 1 or fail
        items[1].body_lines.length > 1 or fail
      end

      it "the item that offered 4 lines of description was cut off at 3" do

        _item = _second_section.items.fetch 0
        _item.body_lines.length == 2 or fail
      end

      it "there is 1 blank line between the first and second section" do

        a = _first_section.items.fetch( 0 ).body_lines
        a[ -1 ].is_blank or fail
        a.length == 1 or fail
      end

      it "there are no blank lines between the first and second items (in sect 2)" do

        _items = _second_section.items
        _items[ 0 ].body_lines[ -1 ].is_blank and fail
      end

      it "singular section is singular" do

        _first_section.first_string == "bone:" or fail
      end

      it "plural section is plural" do

        _second_section.first_string == "organs:" or fail
      end
    end

    def _first_section
      _state.screen.section_at_index 0
    end

    def _second_section
      _state.screen.section_at_index 1
    end

    def _screen
      _state.screen
    end
  end
end
# #history: moved here from [br]
