module Skylab::Human

  class NLP::EN::Contextualization

    class Models_::InflectedParts

      class << self
        def the_empty_instance
          @___ ||= self.begin.freeze
        end

        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize
        @inflected_verb_string = nil
        @prefixed_cojoinder = nil
        @suffixed_cojoinder = nil
        @verb_object_string = nil
        @verb_subject_string = nil
      end

      attr_accessor(
        :inflected_verb_string,
        :prefixed_cojoinder,
        :suffixed_cojoinder,
        :verb_object_string,
        :verb_subject_string,
      )

      def to_string
        to_phrase_assembly_.flush_to_string
      end

      def to_phrase_assembly_

        as = Home_::PhraseAssembly.begin_phrase_builder

        as.add_any_string @prefixed_cojoinder

        as.add_any_string @verb_subject_string

        as.add_any_string @inflected_verb_string

        as.add_any_string @verb_object_string

        as.add_any_string @suffixed_cojoinder

        as
      end
    end
  end
end
# #history: broke out of core
