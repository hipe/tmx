module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::First_Line_Map_via_Lemmas_and_Lemmato_Trilean_Idiom::Idiom_that_Is_Predicate_Mode_While_Frobbing ; class << self

      def via_magnetic_parameter_store ps

        -> line do
          __map_line line, ps
        end
      end

      alias_method :[], :via_magnetic_parameter_store

      def __map_line line, ps
        lc = Magnetics_::Line_Contextualization_via_Line[ line ]
        lemz = ps.lemmas

        vl = lemz.verb_lemma_string
        _frobbing = if vl
          Home_::NLP::EN::POS.progressive_verb vl
        else
          'processing request'
        end

        # we don't want: "while left shark was frobing, .."
        # we do want:    "while frobing, left shark .."
        # (where ".." is "was converted successfully.")

        lc.define_prefixed_string_via_inflected_parts do |ip|
          ip.prefixed_cojoinder = "while #{ _frobbing },"
          ip.verb_subject_string = lemz.verb_subject_string
          ip.verb_object_string = lemz.verb_object_string
        end

        lc.to_string
      end
    end ; end
  end
end
# #history: born at the death of 'butter', reconsitituted from the ether
