module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Line_Parts_via_Line_and_Event_and_Trilean_that_is_Negative

      # (see client comments about the scope of this)

      class << self
        def via_magnetic_parameter_store ps
          new( ps ).execute
        end
        private :new
      end  # >>

      def initialize line_contextualization
        @_ = line_contextualization
        @event = line_contextualization.event
      end

      def execute

        vl = @event.verb_lexeme
        if vl
          v_s = vl.lemma_string
        end

        if @event.respond_to? :noun_lexeme
          nl = @event.noun_lexeme
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

          _ = as.string_via_finish
          @_.mutate_line_parts_by do |mlp|
            mlp.prefix = _
          end
        end

        NIL_
      end
    end
  end
end
