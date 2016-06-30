module Skylab::Human

  class NLP::EN::Contextualization

    class As_Completion___ < Here_::First_Line_Contextualization_

      # (see client comments about the scope of this)

      def when_event_
        if @event_.respond_to? :inflected_noun
          if looks_like_one_word_
            if @event_.verb_lexeme
              do_as__ :when_event_, Here_::As_While_
            end
          else
            ___do_thing_with_colon
          end
        end
      end

      def ___do_thing_with_colon

        ev = @event_
        n_s = ev.inflected_noun
        v_s = ev.verb_lexeme.preterite

        @prefix_ = if n_s
          "#{ v_s } #{ n_s }: "
        else
          v_s
        end

        NIL_
      end
    end
  end
end
