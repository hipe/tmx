module Skylab::Callback

  class Event

    module Wrappers__

      class Signature

        def self.call_via_arglist a
          new a
        end

        def initialize a
          @nf, @ev = a
        end

        attr_reader :ev

        def new_with_event ev
          dup.__init_otr( ev )
        end

        protected def __init_otr ev
          @ev = ev ; self
        end

        def inflected_verb
          if @nf.respond_to? :inflected_verb
            @nf.inflected_verb
          else
            @nf.as_human
          end
        end

        def inflected_noun
          if @nf.respond_to? :inflected_noun
            @nf.inflected_noun
          else
            prnt = @nf.parent
            if prnt
              @nf.as_human
            end
          end
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
end
