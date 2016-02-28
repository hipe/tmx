module Skylab::Human

  class NLP::EN::Contextualization

    class As_Negative___ < Here_::First_Line_Contextualization_

      # (see client comments about the scope of this)

      def when_emission_
        NOTHING_
      end

      def when_event_  # ..

        vl = @event_.verb_lexeme
        if vl
          v_s = vl.lemma
        end

        if @event_.respond_to? :noun_lexeme
          nl = @event_.noun_lexeme
          if nl
            n_s = nl.lemma
          end
        end

        if v_s || n_s

          as = Home_::Phrase_Assembly.begin_phrase_builder
          as.add_string "couldn't"
          as.add_any_string v_s
          as.add_any_string n_s
          as.add_string "because"
          as.add_lazy_space

          @prefix_ = as.string_via_finish
        end

        NIL_
      end
    end
  end
end