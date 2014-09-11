module Skylab::Brazen

  class Model_

      class Event_Signature_Wrapper__

        def initialize nf, ev
          @ev = ev ; @nf = nf
        end

        attr_reader :ev

        def inflected_verb
          @nf.inflected_verb
        end

        def inflected_noun
          @nf.inflected_noun
        end

        def to_event
          @ev.to_event
        end

        def terminal_channel_i
          @ev.terminal_channel_i
        end

        def render_all_lines_into_under y, expag
          @ev.render_all_lines_into_under y, expag
        end

        def verb_lexeme
          @nf.verb_lexeme
        end

        def noun_lexeme
          @nf.noun_lexeme
        end
      end

  end
end
