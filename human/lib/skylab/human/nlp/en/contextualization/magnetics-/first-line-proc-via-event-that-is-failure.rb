module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::First_Line_Proc_via_Event_that_Is_Failure ; class << self

      def mutate_line_contextualization_ lc, ev

        vl = ev.verb_lexeme
        if vl
          v_s = vl.lemma_string
        end

        if ev.respond_to? :noun_lexeme
          nl = ev.noun_lexeme
          if nl
            n_s = nl.lemma_string
          end
        end

        if v_s || n_s

          as = Home_::Phrase_Assembly.begin_phrase_builder
          as.add_string "couldn't"
          as.add_any_string v_s
          as.add_any_string n_s
          as.add_string "because"
          as.add_lazy_space

          _ = as.flush_to_string
          lc.mutate_line_parts_by do |mlp|  # #spot-5
            mlp.prefixed_string = _
          end
        end

        NIL_
      end
    end ; end
  end
end
