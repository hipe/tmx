require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - criteria - library - delayed tail" do

    TS_[ self ]
    use :criteria_magnetics

    it "build this simplest of grammars" do  # #lends-coverage to [#pa-010.1]

      _simplest_width
    end

    it "use it for a \"point\" expression" do

      @subject_object_ = _simplest_width

      on = against_ input_stream_via_array %w( is 3 feet wide )

      expect( on.symbol ).to eql :point

      a = on.value
      expect( a.first ).to eql 3
      expect( a.fetch 1 ).to eql :foot_unit
    end

    it "use it for an OR-list" do

      @subject_object_ = _simplest_width

      on = against_ input_stream_via_array %w( is 6 or 7 feet wide )

      a = on.value
      expect( a.fetch 1 ).to eql :foot_unit
      expect( a.first.map( & :value ) ).to eql [ 6, 7 ]
    end

    it "you've gotta finish it - the 'wide' part is not optional" do

      @subject_object_ = _simplest_width

      st = input_stream_via_array %w( is 7 feet )
      on = against_ st
      expect( on ).to be_nil
      expect( st.current_index ).to be_zero
    end

    attr_reader :subject_object_


    # ~ hook-outs & support

    memoize :_simplest_width do

      n11n = Home_.lib_.basic::Number::Normalization.with(
        :number_set, :integer, :minimum, 0 ).to_parser_proc

      subject_module_::Association_Adapter.with(

        :verb_lemma, 'be',

        :named_functions,

          :point, :sequence, [

            :alternation, [

              :separated_list,
                :separator, :keyword, 'or',
                :item, :proc, n11n,

              :proc, n11n

            ],

            :regex, /\Afeet|foot\z/, :becomes_symbol, :foot_unit,

            :keyword, 'wide' ] )
    end

    def grammatical_context_
      grammatical_context_for_singular_subject_number_
    end
  end
end
