require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - criteria - library - funadmentals" do

    TS_[ self ]
    use :criteria_magnetics

    it "loads" do
      subject_module_
    end

    it "you gotta have a verb lemma" do

      begin
        subject_module_::Association_Adapter.with
      rescue ::Skylab::Fields::MissingRequiredAttributes => e
      end

      e.message == "missing required parameter 'verb_lemma_and_phrase_head_string_array'" || fail
    end

    it "make a minimal association adapter" do

      _o = _min_assoc_adptr
      expect( _o.instance_variable_get :@verb_lemma_and_phrase_head_string_array ).to eql %w( be )
    end

    it "the named functions gets parsed" do

      _o = _min_assoc_adptr

      bx = _o.named_functions_
      _f = bx.fetch :the_ON_form
      expect( _f.formal_string ).to eql 'on'

      _f = bx.fetch :the_OFF_form
      expect( _f.formal_string ).to eql 'off'
    end

    it "parse the first case" do

      on = parse_against_ 'is', 'on'
      expect( on.symbol ).to eql :the_ON_form
      expect( on.value ).to eql :on
    end

    it "parse the second case" do

      on = parse_against_ 'is', 'off'
      expect( on.symbol ).to eql :the_OFF_form
      expect( on.value ).to eql :off
    end

    it "parse neither" do

      st = input_stream_containing 'is', 'of'
      _x = against_ st
      expect( st.current_index ).to be_zero
      expect( _x ).to be_nil
    end

    it "correctly avoids an OR that might belong to a higher up" do

      _st = input_stream_via_array %w( is off or wazoozle )
      _does_not_munge _st
    end

    it "correctly avoids munging in others even if same verb" do

      _st = input_stream_via_array %w( is off or is not availble )
      _does_not_munge _st
    end

    def _does_not_munge st

      _x = against_ st
      expect( _x.symbol ).to eql :the_OFF_form
      expect( st.current_index ).to eql 2  # the 'or' token
    end

    it "catches the minimal OR case when at the end" do

      st = input_stream_via_array %w( is off or on )
      _x = against_ st
      _off_or_on _x
      expect( st.unparsed_exists ).to eql false
    end

    it "catches the minimal OR case with something after it" do

      st = input_stream_via_array %w( is off or on hi )
      _x = against_ st
      _off_or_on _x
      expect( st.unparsed_exists ).to eql true
      expect( st.current_index ).to eql 4
    end

    it "doesn't detect redundancy" do

      st = input_stream_via_array %w( is off and off )
      x = against_ st
      expect( x.symbol ).to eql :and
      expect( x.a.map( & :symbol ) ).to eql [ :the_OFF_form, :the_OFF_form ]
    end

    it "repeating the verb in the minmal case gets you the same thing" do

      st = input_stream_via_array %w( is off or is on )
      _x = against_ st
      _off_or_on _x
    end

    it "ditto with something after it" do

      st = input_stream_via_array %w( is off or is on hi )
      _x = against_ st
      _off_or_on _x
      _common_unparsed_exists st
    end

    it "correctly avoids munging in the verb case" do

      st = input_stream_via_array %w( is off or is on or is not available )
      _x = against_ st
      _off_or_on _x
      _common_unparsed_exists st
    end

    it "trippel (short case)" do

      st = input_stream_via_array %w( is off or on or off or hi )
      _x = against_ st
      expect( _x.length ).to eql 3
      expect( st.current_index ).to eql 6
      expect( st.current_token_object.value ).to eql 'or'
    end

    it "trippel (long case)" do

      st = input_stream_via_array %w( is off or is on or is off or is x )
      _x = against_ st
      expect( _x.length ).to eql 3
      expect( st.current_index ).to eql 8  # 'or'
    end

    # ~ common results

    def _off_or_on x

      expect( x.symbol ).to eql :or
      expect( x.a.first.symbol ).to eql :the_OFF_form
      expect( x.a.last.symbol ).to eql :the_ON_form
    end

    def _common_unparsed_exists st

      expect( st.unparsed_exists ).to eql true
      expect( st.current_index ).to eql 5
    end

    # ~ hook-outs & support

    def subject_object_
      _min_assoc_adptr
    end

    def grammatical_context_
      grammatical_context_for_singular_subject_number_
    end

    memoize :_min_assoc_adptr do

      subject_module_::Association_Adapter.with(
        :verb_lemma, 'be',
        :named_functions,
          :the_ON_form, :keyword, 'on',
          :the_OFF_form, :keyword, 'off'
      )
    end
  end
end
# the criteria that the node has tag "#done" or tag "#hole" and that the node has no extended content
