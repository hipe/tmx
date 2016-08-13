module Skylab::Human

  class NLP::EN::Contextualization

    Magnetics_::String_via_Surface_Parts = -> o do

        as = Home_::Phrase_Assembly.begin_phrase_builder

        as.add_any_string o.prefixed_cojoinder

        as.add_any_string o.verb_subject

        as.add_any_string o.inflected_verb

        as.add_any_string o.verb_object

        as.add_any_string o.suffixed_cojoinder

        as.string_via_finish

    end
  end
end
# #history: broke out of core
