require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node criteria - library (02)" do

    extend TS_
    use :expect_event
    use :criteria_library_support

    it "build this adapter" do

      _color_assoc_adaptr
    end

    it "ambiguity is ambiguous" do

      st = input_stream_via_array %w( is blue and pink or green )
      _x = against_ st, & handle_event_selectively
      _x.should eql false
      _ev = expect_not_OK_event :ambiguous
      black_and_white( _ev ).should eql(
        "'or' is ambiguous here because of a previous \"and\"" )
      st.current_index.should eql 4
    end

    it "experimentally, ambiguity can be resolved by a context pop" do

      st = input_stream_via_array %w( is blue and pink or is green )
      _s = _visual_tree_against st
      _s.should eql __tree_viz_for_context_pop
    end

    def __tree_viz_for_context_pop

      <<-HERE.unindent
        or
         |- and
         |   |- blu
         |   •- pin
         •- grn
      HERE
    end

    it "ambiguity can still happen even with a context pop" do

      st = input_stream_via_array %w(
        is pink and blue
        or is green
        and is lavender )

      _x = against_ st, & handle_event_selectively

      expect_not_OK_event :ambiguous
      _x.should eql false
    end

    it "branches down" do

      st = input_stream_via_array %w( is blue and pink or is green or lavender )

      _s = _visual_tree_against st

      _expect_parsed_everything st

      _s.should eql __tree_viz_for_branch_down
    end

    def __tree_viz_for_branch_down

      <<-HERE.unindent
        or
         |- and
         |   |- blu
         |   •- pin
         •- or
             |- grn
             •- lav
      HERE
    end

    it "sort of complicated tree with some left over" do

      st = input_stream_via_array %w( is pink or is blue and lavender or is green )

      _x = against_ st

      _s = _x.to_ascii_visualization_string_
      _s.should eql __tree_viz_for_up_down_up
    end

    def __tree_viz_for_up_down_up

      <<-HERE.unindent
        or
         |- pin
         |- and
         |   |- blu
         |   •- lav
         •- grn
      HERE
    end

    it "contrived down up down" do

      st = input_stream_via_array %w( is pink or blue or
        is green or is lavender and pink or is blue )

      _s = _visual_tree_against st
      _s.should eql __tree_viz_for_down_up_down_up
    end

    def __tree_viz_for_down_up_down_up

      <<-HERE.unindent
        or
         |- or
         |   |- pin
         |   •- blu
         |- grn
         |- and
         |   |- lav
         |   •- pin
         •- blu
      HERE
    end

    def _expect_parsed_everything st

      if st.unparsed_exists

        fail "did not parse token #{ st.current_index }: #{
          }#{ st.current_token_object.value_x.inspect }"
      end
    end

    def _visual_tree_against st

      _x = against_ st
      _x.to_ascii_visualization_string_
    end

    # ~ hook-outs & support

    def subject_object_
      _color_assoc_adaptr
    end

    memoize_ :_color_assoc_adaptr do

      subject_module_::Association_Adapter.new_with(
        :verb_lemma, 'is',
        :named_functions,
          :pin, :keyword, 'pink',
          :blu, :keyword, 'blue',
          :grn, :keyword, 'green',
          :lav, :keyword, 'lavender'
      )
    end
  end
end
