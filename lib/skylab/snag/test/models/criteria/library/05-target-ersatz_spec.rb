require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node criteria - library (05 - \"target ersatz\")" do

    extend TS_
    use :criteria_library_support

    it "build" do
      _ersatz_domain
    end

    it "go" do

      o = _ersatz_domain.parse_query_via_word_array(
        %w( the thing is marked with "sale" or "clearance" and
            has no particular shortcomings ) )

      o.name_symbol.should eql %i( Thing )

      t = o.value_x
      t.a.first.a.first.value_x[ :body ].should eql 'sale'
      t.a.first.a.last.value_x[ :body ].should eql 'clearance'

      o = t.a.last
      o.associated_model_identifier.should eql [:Shortcomings]
      o.value_x.first.should eql :no

      _s = t.to_ascii_visualization_string_
      _s.should eql __this_tree
    end

    def __this_tree
      <<-HERE.unindent
        and
         |- or
         |   |- the_sticker
         |   •- the_sticker[1]
         •- yes_or_no
      HERE
    end

    memoize_ :_ersatz_domain do

      mod = subject_module_

      sticker = mod::Association_Adapter.new_with(

        :verb_lemma_and_phrase_head_s_a, %w( is marked with ),

        :named_functions,

          :the_sticker, :regex,
            /\A" (?<body> (?: \\["\\] | [^\\"] )+ ) "\z/x )

      shortcomings = mod::Association_Adapter.new_with(

        :verb_lemma, 'has',

        :named_functions,

          :yes_or_no, :sequence, [
            :zero_or_one, :keyword, 'no',
            :keyword, 'particular',
            :keyword, 'shortcomings' ] )

      da = mod::Domain_Adapter.new :_no_kernel_for_this_test_

      da.under_target_model_add_association_adapter :Sticker, sticker
      da.under_target_model_add_association_adapter :Shortcomings, shortcomings

      da.source_and_target_models_are_associated :Thing, :Shortcomings
      da.source_and_target_models_are_associated :Thing, :Sticker

      da
    end
  end
end
