module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Line_Parts_via_Line_and_Event_that_is_Completion

      class << self
        def via_magnetic_parameter_store ps
          new( ps ).execute
        end
        private :new
      end  # >>

      def initialize client

        @_ = client
        @event = client.event
      end

      def execute

        if @event.respond_to? :inflected_noun

          if @_.content_string_looks_like_one_word_

            if @event.verb_lexeme

              Magnetics_::Line_Parts_via_Line_and_Event_and_Trilean_that_is_Positive.via_magnetic_parameter_store @_
            end
          else
            __do_thing_with_colon
          end
        end
        NIL_
      end

      def __do_thing_with_colon

        ev = @event
        n_s = ev.inflected_noun
        v_s = ev.verb_lexeme.preterite

        _ = if n_s
          "#{ v_s } #{ n_s }: "
        else
          v_s
        end

        @_.mutate_line_parts_by do |mlp|
          mlp.prefix = _
        end

        NIL_
      end
    end
  end
end
