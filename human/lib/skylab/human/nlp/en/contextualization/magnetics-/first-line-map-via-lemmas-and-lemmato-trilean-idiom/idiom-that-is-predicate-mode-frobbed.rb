module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::First_Line_Map_via_Lemmas_and_Lemmato_Trilean_Idiom::Idiom_that_Is_Predicate_Mode_Frobbed ; class << self

      def via_magnetic_parameter_store ps

        -> line do
          __map_line line, ps
        end
      end

      alias_method :[], :via_magnetic_parameter_store

      def __map_line line, ps
        lc = Magnetics_::Line_Contextualization_via_Line[ line ]
        lemz = ps.lemmas

        # we don't want: "left shark sended item .."
        # we do want:    "left shark .."
        # (where ".." is "sent item")

        lc.define_prefixed_string_via_inflected_parts do |ip|
          ip.verb_subject_string = lemz.verb_subject_string
        end

        lc.to_string
      end
    end ; end
  end
end
# #history: rename and rewrite of unknown origin at magnetic switch advent
