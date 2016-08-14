module Skylab::Human

  class NLP::EN::Contextualization

    Magnetics_::Surface_Parts_via_Three_Parts_Of_Speech_when_Successful_Classically = -> three_POS do

      # -

        vl = three_POS.verb_lemma

        _ = if vl
          Home_::NLP::EN::POS.preterite_verb vl
        else
          'succeeded'
        end

        o = Models_::Surface_Parts.begin_via_parts_of_speech three_POS
        o.inflected_verb = _
        o

      # -
    end
  end
end
# #history: broke out of only caller
