module Skylab::Autonomous_Component_System::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_41_Sentence

      class << self
        alias_method :new_cold_root_ACS_for_expect_root_ACS, :new
        private :new
      end  # >>

      # -

        def __subject__component_association
          Here_::Class_92_Normal_Primitive_Lemma
        end

        def __verb_phrase__component_association
          Verb_Phrase
        end

        def _set_subject x
          @subject = x ; nil
        end

        def _set_verb_phrase o
          @verb_phrase = o ; nil
        end
      # -

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
      end
    end
  end
end
