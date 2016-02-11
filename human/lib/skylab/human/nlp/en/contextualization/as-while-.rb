module Skylab::Human

  class NLP::EN::Contextualization

    class As_While_ < Here_::First_Line_Contextualization_

      # (see client comments about the scope of this)

      def when_emission_
        NOTHING_
      end

      def when_event_
        if @event_.respond_to? :inflected_noun
          ___ham
        end
      end

      def ___ham

        ev = @event_

        n_s = ev.inflected_noun
        v_s = ev.verb_lexeme.progressive

        as = Here_::Phrase_Assembly.new
        as.add_space

        one = looks_like_one_word_

        if one or n_s.include? SPACE_

          # ! "while a workspace opening" [br]
          as.add_string v_s
          as.add_any_string n_s
        else

          # "while fish eating.." [hu]
          as.add_any_string n_s
          as.add_string v_s
        end

        gerund_phrase = as.build_string_

        if one
          @content_.concat gerund_phrase
        else
          @content_[ 0, 0 ] = "while#{ gerund_phrase }, "
        end

        NIL_
      end

      attr_reader(
        :content_, :prefix_,
      )
    end
  end
end
