module Skylab::Human

  class NLP::EN::Contextualization

    class Models_::Inflected_Parts

      class << self
        def begin_via_lemmas lemz
          new.__init_via_lemmas lemz
        end
        private :new
      end  # >>

      def __init_via_lemmas lemz
        @inflected_verb = nil
        @prefixed_cojoinder = nil
        @verb_object = lemz.verb_object
        @verb_subject = lemz.verb_subject
        @suffixed_cojoinder = nil
        self
      end

      attr_accessor(
        :inflected_verb,
        :prefixed_cojoinder,
        :suffixed_cojoinder,
        :verb_object,
        :verb_subject,
      )

      def to_string__
        to_phrase_assembly__.flush_to_string
      end

      def to_phrase_assembly__

        as = Home_::Phrase_Assembly.begin_phrase_builder

        as.add_any_string @prefixed_cojoinder

        as.add_any_string @verb_subject

        as.add_any_string @inflected_verb

        as.add_any_string @verb_object

        as.add_any_string @suffixed_cojoinder

        as
      end
    end
  end
end
# #history: broke out of core
