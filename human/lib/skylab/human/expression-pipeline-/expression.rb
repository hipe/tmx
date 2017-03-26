module Skylab::Human

  module ExpressionPipeline_

    class Expression  # [here] only. (2x)

      # (introduction to parent node at #spot1.6)

      # <-

    class << self

      def list_argument_via_array a
        ::Kernel._OKAY
        ExpressionPipeline_::IdeaArgumentAdapter_via_Nounish_.via_array a
      end

      def match_for_idea__ idea
        ExpressionPipeline_::Score_via_Idea_and_Frame___[ idea, self ]
      end

      def new_session_via_sexp__ x_a  # assume receiver is an e.f subclass
        via_idea_ ExpressionPipeline_::Idea_.interpret_ Scanner_[ x_a ]
      end

      def via_idea_ x
        new x
      end

      private :new
    end  # >>

    def to_string_with_punctuation_hack_ s_a
      Home_::PhraseAssembly::Sentence_string_head_via_words[ s_a ]
    end
      # -
    end
  end
end
