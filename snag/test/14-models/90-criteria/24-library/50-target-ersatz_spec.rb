require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - criteria - library - target ersatz" do

    TS_[ self ]
    use :criteria_magnetics

    it "build" do
      _ersatz_domain
    end

    it "go" do

      o = _ersatz_domain.new_criteria_tree_via_word_array %w(
            the thing is marked with "sale" or "clearance" and
            has no particular shortcomings
      )

      o.association == %i( Thing ) || fail

      t = o.value
      expect( t.a.first.a.first.value[ :body ] ).to eql 'sale'
      expect( t.a.first.a.last.value[ :body ] ).to eql 'clearance'

      o = t.a.last
      expect( o.associated_model_identifier ).to eql [:Shortcomings]
      expect( o.value.first ).to eql :no

      _s = t.to_ascii_visualization_string_
      expect( _s ).to eql __this_tree
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

    memoize :_ersatz_domain do

      mod = subject_module_

      sticker = mod::Association_Adapter.with(

        :verb_lemma_and_phrase_head_string_array, %w( be marked with ),

        :named_functions,

          :the_sticker, :regex,
            /\A" (?<body> (?: \\["\\] | [^\\"] )+ ) "\z/x )

      shortcomings = mod::Association_Adapter.with(

        :verb_lemma, 'have',

        :named_functions,

          :yes_or_no, :sequence, [
            :zero_or_one, :keyword, 'no',
            :keyword, 'particular',
            :keyword, 'shortcomings' ] )

      da = mod::DomainAdapter.__begin_mutable_me

      da.under_target_model_add_association_adapter :Sticker, sticker
      da.under_target_model_add_association_adapter :Shortcomings, shortcomings

      da.source_and_target_models_are_associated :Thing, :Shortcomings
      da.source_and_target_models_are_associated :Thing, :Sticker

      da
    end
  end
end
