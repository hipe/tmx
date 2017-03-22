require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - criteria - library - verb sharing" do

    TS_[ self ]
    use :criteria_magnetics

    it "build" do
      _the_first_domain
    end

    it "go" do

      o = _the_first_domain.new_criteria_tree_via_word_array(
        %w( things that are 6 feet wide or 10 feet tall ) )

      o.name_x.should eql %i( Thing )

      o = o.value_x
      o.symbol.should eql :or
      a = o.a
      a.length.should eql 2

      o = a.first
      o.symbol.should eql :point
      o.value_x.should eql [ 6, :foot_unit, :wide ]
      o.associated_model_identifier.should eql %i( Width )

      o = a.last
      o.symbol.should eql :point
      o.value_x.should eql [ 10, :foot_unit, :tall ]
      o.associated_model_identifier.should eql %i( Height )

    end

    memoize :_the_first_domain do

      mod = subject_module_

      n11n = Home_.lib_.basic::Number::Normalization.with(
        :number_set, :integer, :minimum, 0 ).to_parser_proc

      _h = mod::Association_Adapter.with(

        :verb_lemma, 'be',

        :named_functions,

          :point, :sequence, [

            :proc, n11n,

            :regex, /\Afeet|foot\z/, :becomes_symbol, :foot_unit,

            :keyword, 'tall' ] )

      _w = mod::Association_Adapter.with(

        :verb_lemma, 'be',

        :named_functions,

          :point, :sequence, [

            :proc, n11n,

            :regex, /\Afeet|foot\z/, :becomes_symbol, :foot_unit,

            :keyword, 'wide' ] )

      da = mod::DomainAdapter.__begin_mutable_me
      da.under_target_model_add_association_adapter %i( Height ), _h
      da.under_target_model_add_association_adapter :Width, _w
      da.source_and_target_models_are_associated %i( Thing ), :Height
      da.source_and_target_models_are_associated :Thing, %i( Width )
      da
    end
  end
end
