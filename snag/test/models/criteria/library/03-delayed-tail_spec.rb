require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - criteria - library (03)" do

    extend TS_
    use :criteria_library_support

    it "build this simplest of grammars" do

      _simplest_width
    end

    it "use it for a \"point\" expression" do

      @subject_object_ = _simplest_width

      on = against_ input_stream_via_array %w( is 3 feet wide )

      on.symbol.should eql :point

      a = on.value_x
      a.first.should eql 3
      a.fetch( 1 ).should eql :foot_unit
    end

    it "use it for an OR-list" do

      @subject_object_ = _simplest_width

      on = against_ input_stream_via_array %w( is 6 or 7 feet wide )

      a = on.value_x
      a.fetch( 1 ).should eql :foot_unit
      a.first.map( & :value_x ).should eql [ 6, 7 ]
    end

    it "you've gotta finish it - the 'wide' part is not optional" do

      @subject_object_ = _simplest_width

      st = input_stream_via_array %w( is 7 feet )
      on = against_ st
      on.should be_nil
      st.current_index.should be_zero
    end

    attr_reader :subject_object_


    # ~ hook-outs & support

    memoize :_simplest_width do

      n11n = Home_.lib_.basic::Number.normalization.new_with(
        :number_set, :integer, :minimum, 0 ).to_parser_proc

      subject_module_::Association_Adapter.new_with(

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
