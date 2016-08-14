module Skylab::Human

  class NLP::EN::Contextualization

    _FAILED = nil

    Magnetics_::Surface_Parts_via_Three_Parts_Of_Speech_when_Failed_Classically = -> three_POS do

      # -

        vl = three_POS.verb_lemma

        _ = if vl
          "failed to #{ vl }"
        else
          _FAILED ||= "failed".freeze
        end

        o = Models_::Surface_Parts.begin_via_parts_of_speech three_POS
        o.suffixed_cojoinder = NONE_
        o.inflected_verb = _
        o

      # -
    end
  end
end
# #history: broke out of only caller
