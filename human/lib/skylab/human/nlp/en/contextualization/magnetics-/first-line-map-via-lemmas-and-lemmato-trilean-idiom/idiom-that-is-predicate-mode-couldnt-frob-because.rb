module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::First_Line_Map_via_Lemmas_and_Lemmato_Trilean_Idiom::Idiom_that_Is_Predicate_Mode_Couldnt_Frob_Because ; class << self

      def via_magnetic_parameter_store ps

        -> line do
          __map_line line, ps
        end
      end

      alias_method :[], :via_magnetic_parameter_store

      def __map_line line, ps

        lc = Magnetics_::Line_Contextualization_via_Line[ line ]
        lemz = ps.lemmas

        # we don't want: "left shark failed to frob item .."
        # we do want:    "couldn't frob item because left shark .."
        # (where .. is "had problems")

        lc.define_prefixed_string_via_inflected_parts do |ip|
          ip.inflected_verb_string = "couldn't #{ lemz.verb_lemma_string }"
          ip.verb_object_string = lemz.verb_object_string
          ip.suffixed_cojoinder = "#{ BECAUSE_ } #{ lemz.verb_subject_string }"
        end

        lc.to_string
      end

    end ; end
  end
end
# #history: a reconception of what used to be the 'butter' but is now the predicate-mode idioms
