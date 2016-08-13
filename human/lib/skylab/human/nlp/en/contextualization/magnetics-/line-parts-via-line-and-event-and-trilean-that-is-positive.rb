module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Line_Parts_via_Line_and_Event_and_Trilean_that_is_Positive

      # (see client comments about the scope of this)

      class << self
        def via_magnetic_parameter_store ps
          new( ps ).execute
        end
        private :new
      end  # >>

      def initialize ps
        @_ = ps
        @event = ps.event
      end

      def execute

        if @event.respond_to? :inflected_noun
          ___ham
        end  # otherwise nothing
        NIL_
      end

      def ___ham

        ev = @event

        n_s = ev.inflected_noun
        v_s = ev.verb_lexeme.progressive

        as = Home_::Phrase_Assembly.begin_phrase_builder
        as.add_lazy_space

        one = @_.content_string_looks_like_one_word_

        if one or n_s.include? SPACE_

          # ! "while a workspace opening" [br]
          as.add_string v_s
          as.add_any_string n_s
        else

          # "while fish eating.." [hu]
          as.add_any_string n_s
          as.add_string v_s
        end

        gerund_phrase = as.string_via_finish

        @_.mutate_line_parts_by do |mlp|

          eek_mutable = mlp.content

          if one
            eek_mutable.concat gerund_phrase
          else
            eek_mutable[ 0, 0 ] = "while#{ gerund_phrase }, "
          end
        end

        NIL_
      end
    end
  end
end
