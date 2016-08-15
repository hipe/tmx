module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::First_Line_Proc_via_Event_that_Is_Completion ; class << self

      def mutate_line_contextualization_ lc, ev

        if ev.respond_to? :inflected_noun

          if lc.content_string_looks_like_one_word_

            if ev.verb_lexeme

              Magnetics_::First_Line_Proc_via_Event_that_Is_Success[ lc, ev ]
            end
          else
            __do_the_thing_with_the_colon lc, ev
          end
        end
      end

      def __do_the_thing_with_the_colon lc, ev

        n_s = ev.inflected_noun
        v_s = ev.verb_lexeme.preterite

        _ = if n_s
          "#{ v_s } #{ n_s }: "
        else
          v_s
        end

        lc.mutate_line_parts_by do |mlp|  # #spot-5
          mlp.prefixed_string = _
        end

        NIL_
      end
    end ; end
  end
end
