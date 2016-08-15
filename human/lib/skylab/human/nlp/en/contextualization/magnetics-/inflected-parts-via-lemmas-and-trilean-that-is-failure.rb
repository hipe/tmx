module Skylab::Human

  class NLP::EN::Contextualization

    _FAILED = nil

    Magnetics_::Inflected_Parts_via_Lemmas_and_Trilean_that_Is_Failure = -> lemmas do

      # -

        vl = lemmas.verb_lemma

        _ = if vl
          "failed to #{ vl }"
        else
          _FAILED ||= "failed".freeze
        end

        o = Models_::Inflected_Parts.begin_via_lemmas lemmas
        o.suffixed_cojoinder = NONE_
        o.inflected_verb = _
        o

      # -
    end
  end
end
# #history: broke out of only caller
