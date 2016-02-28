module Skylab::Human

  module Sexp

    class Magnetic_Expression_Session

      # theory of "expression frames" at [#034]
      # <-

    class << self

      def list_argument_via_array a
        Here_::Idea_Argument_Adapter_for_Nounish_.new_via_array a
      end

      def match_for_idea idea
        Here_::Build_score_against_idea_of_frame___[ idea, self ]
      end

      def new_via_iambic x_a  # assume receiver is an e.f subclass

        new_via_idea Here_::Idea_.new_via_iambic x_a
      end

      def new_via_idea x
        new x
      end

      private :new
    end  # >>

    def to_string_with_punctuation_hack_ s_a
      Home_::Phrase_Assembly::Sentence_string_head_via_words[ s_a ]
    end
      # -
    end
  end
end
