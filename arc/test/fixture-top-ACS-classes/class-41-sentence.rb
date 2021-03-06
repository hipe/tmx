module Skylab::Arc::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_41_Sentence

      class << self
        alias_method :new_cold_root_ACS_for_want_root_ACS, :new
        private :new
      end  # >>

      # -

        ACS_FIX_ORDER = true  # :(

        def __subject__component_association
          yield :order_ordinal, 100
          Here_::Class_92_Normal_Primitive_Lemma
        end

        def __verb_phrase__component_association
          yield :order_ordinal, 300
          Verb_Phrase
        end

        def _set_subject x
          @subject = x ; nil
        end

        def set_verb_phrase_for_want_root_ACS o
          @verb_phrase = o ; nil
        end

      # -

      def SUBJ
        @subject
      end

      def VP
        @verb_phrase
      end

      class Verb_Phrase

        Be_compound[ self ]

        def __verb__component_association
          Here_::Class_92_Normal_Primitive_Lemma
        end

        def __object__component_association
          Here_::Class_92_Normal_Primitive_Lemma
        end

        def _set_verb x
          @verb = x ; nil
        end

        def _set_object x
          @object = x ; nil
        end

        def V
          @verb
        end

        attr_reader :object
        alias_method :O, :object
        undef_method :object
      end
    end
  end
end
