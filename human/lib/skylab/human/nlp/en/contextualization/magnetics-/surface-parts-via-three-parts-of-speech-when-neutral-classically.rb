module Skylab::Human

  class NLP::EN::Contextualization

    Magnetics_::Surface_Parts_via_Three_Parts_Of_Speech_when_Neutral_Classically = -> three_POS do

      # -

        vl = three_POS.verb_lemma

        _ing = if vl
          Home_::NLP::EN::POS.progressive_verb vl
        else
          'processing request'
        end

        _ = three_POS.verb_subject

        _inflected_verb = if _
          "was #{ _ing }"
        else
          _ing
        end

        o = Models_::Surface_Parts.begin_via_parts_of_speech three_POS
        o.prefixed_cojoinder = 'while'
        o.inflected_verb = _inflected_verb
        o.suffixed_cojoinder = ','
        o

      # -
    end
  end
end
# #history: broke out of only caller
