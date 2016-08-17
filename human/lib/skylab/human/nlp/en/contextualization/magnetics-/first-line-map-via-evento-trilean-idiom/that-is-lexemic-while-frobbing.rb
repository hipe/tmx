module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::First_Line_Proc_via_Event_that_Is_Success ; class << self

      def mutate_line_contextualization_ lc, ev

        if ev.respond_to? :inflected_noun
          __work lc, ev
        end  # otherwise nothing
        NIL_
      end

      alias_method :[], :mutate_line_contextualization_

      def __work lc, ev

        n_s = ev.inflected_noun
        v_s = ev.verb_lexeme.progressive

        as = Home_::Phrase_Assembly.begin_phrase_builder
        as.add_lazy_space

        one = lc.content_string_looks_like_one_word_

        if one or n_s.include? SPACE_

          # ! "while a workspace opening" [br]
          as.add_string v_s
          as.add_any_string n_s
        else

          # "while fish eating.." [hu]
          as.add_any_string n_s
          as.add_string v_s
        end

        gerund_phrase = as.flush_to_string

        lc.mutate_line_parts_by do |mlp|  # #spot-5

          eek_mutable = mlp.normalized_original_content_string

          if one
            eek_mutable.concat gerund_phrase
          else
            eek_mutable[ 0, 0 ] = "while#{ gerund_phrase }, "
          end
        end

        NIL_
      end
    end ; end
  end
end
