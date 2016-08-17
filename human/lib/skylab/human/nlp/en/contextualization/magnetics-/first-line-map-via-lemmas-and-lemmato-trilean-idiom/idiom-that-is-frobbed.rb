module Skylab::Human

  class NLP::EN::Contextualization

    Magnetics_::Inflected_Parts_via_Lemmas_and_Trilean_that_Is_Success = -> lemmas do

      # -

        vl = lemmas.verb_lemma

        _ = if vl
          Home_::NLP::EN::POS.preterite_verb vl
        else
          'succeeded'
        end

        o = Models_::Inflected_Parts.begin_via_lemmas lemmas
        o.inflected_verb = _
        o

      # -
    end
  end
end
# #history: broke out of only caller
