module Skylab::Common

  class Event

    class Via_signature < Home_::Dyadic

      # :[#051]. #covered-only-by:[bs],[gi]

      # event "signing" is deprecated because it adds complexity without
      # adding commensurate value. but for the point of explaining it,
      # the idea was this: if every event comes from one or another
      # particular action, the idea is that the action "signs" the event
      # (wraps it) with what we now consider the invocation "stack" (just
      # an array of names) so that the modality client can render the
      # action's name as part of expressing the event. we now encourage
      # other means of accessing this "stack" other than wrappin the event,
      # so that there is a more direct relationship between what is emitted
      # and what is received.

      # -

        def initialize name_function, event
          @nf = name_function
          @ev = event
        end

        def execute
          freeze
        end

        attr_reader :ev

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

        def terminal_channel_symbol
          @ev.terminal_channel_symbol
        end

        def express_into_under y, expag
          @ev.express_into_under y, expag
        end

        def verb_lexeme
          @nf.verb_lexeme
        end

        def noun_lexeme
          @nf.noun_lexeme
        end
      # -
    end
  end
end
