module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::First_Line_Map_via_Lemmas_and_Lemmato_Trilean_Idiom::Idiom_that_Is_While_Frobbing ; class << self

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
        ing = if vl
          Home_::NLP::EN::POS.progressive_verb vl
        else
          'processing request'
        end

        vs = lemz.verb_subject_string

        _ivs = if vs
          "was #{ ing }"
        else
          ing
        end

        lc.define_prefixed_string_via_inflected_parts do |ip|
          ip.prefixed_cojoinder = 'while'
          ip.verb_subject_string = vs
          ip.inflected_verb_string = _ivs
          ip.verb_object_string = lemz.verb_object_string
          ip.suffixed_cojoinder = ','
        end

        lc.to_string
      end
    end ; end
  end
end
# #history: broke out of only caller
