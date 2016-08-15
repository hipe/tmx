module Skylab::Human

  class NLP::EN::Contextualization

    Magnetics_::Inflected_Parts_via_Lemmas_and_Trilean_that_Is_Neutral = -> lemmas do

      # -

        vl = lemmas.verb_lemma

        _ing = if vl
          Home_::NLP::EN::POS.progressive_verb vl
        else
          'processing request'
        end

        _ = lemmas.verb_subject

        _inflected_verb = if _
          "was #{ _ing }"
        else
          _ing
        end

        o = Models_::Inflected_Parts.begin_via_lemmas lemmas
        o.prefixed_cojoinder = 'while'
        o.inflected_verb = _inflected_verb
        o.suffixed_cojoinder = ','
        o

      # -
    end
  end
end
# #history: broke out of only caller
