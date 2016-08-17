module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::First_Line_Map_via_Lemmas_and_Lemmato_Trilean_Idiom::Idiom_that_Is_Failed_To_Frob ; class << self

      def via_magnetic_parameter_store ps
        -> line do
          map_line line, ps
        end
      end

      def map_line line, ps

        lc = Magnetics_::Line_Contextualization_via_Line[ line ]
        lemz = ps.lemmas

        _vss = lemz.verb_subject_string

        _ivs = lc.string_via_phrase_assembly do |pa|
          vl = lemz.verb_lemma_string
          if vl
            pa.add_string "failed to #{ vl }"
          else
            pa.add_string "failed"
          end
        end

        lc.define_prefixed_string_via_inflected_parts do |ip|
          ip.verb_subject_string = _vss
          ip.inflected_verb_string = _ivs
          ip.verb_object_string = lemz.verb_object_string
        end

        yield lc if block_given?

        lc.to_string
      end

      alias_method :[], :via_magnetic_parameter_store
    end ; end
  end
end
# #history: broke out of only caller
