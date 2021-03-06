module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::First_Line_Map_via_Evento_Trilean_Idiom::That_Is_Lexemic_Couldnt_Frob_Because ; class << self

      def via_magnetic_parameter_store ps

        -> line do
          __map_line line, ps
        end
      end

      alias_method :[], :via_magnetic_parameter_store

      def __map_line line, ps

        lc = Magnetics_::Line_Contextualization_via_Line[ line ]

        lexz = ps.possibly_wrapped_event  # might be wrapped, might be structured

        vl = lexz.verb_lexeme
        if vl
          s = vl.lemma_string
          if s
            v_s = "couldn't #{ s }"

            if lexz.respond_to? :inflected_noun
              n_s = lexz.inflected_noun
            end

            if ! n_s and lexz.respond_to? :noun_lexeme
              nl = lexz.noun_lexeme
              if nl
                n_s = nl.lemma_string
              end
            end
          end
        end

        # NOTE it's possible that both strings are still nil.
        # we go thru the motions anyway to be touchy

        lc.define_prefixed_string_via_inflected_parts do |ip|

          ip.verb_subject_string = nil  # nothing for now

          ip.inflected_verb_string = v_s

          ip.verb_object_string = n_s

          if v_s
            ip.suffixed_cojoinder = BECAUSE_
          end
        end

        lc.to_string
      end
    end ; end
  end
end
# #history: rename and rewrite of unknown origin at magnetic switch advent
