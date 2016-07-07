module Skylab::Human

  class NLP::EN::Contextualization

    Magnetics_::String_via_Surface_Parts = -> o do

      # -

        as = Home_::Phrase_Assembly.begin_phrase_builder

        as.add_any_string o.initial_phrase_conjunction

        as.add_any_string o.verb_subject

        as.add_any_string o.inflected_verb

        as.add_any_string o.verb_object

        as.string_via_finish

      # -
    end
  end
end
# #history: broke out of core
