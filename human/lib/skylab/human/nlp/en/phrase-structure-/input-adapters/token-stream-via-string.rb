module Skylab::Human

  module NLP::EN

    module Phrase_Structure_

      class Input_Adapters::Token_Stream_via_String

        # just quick & dirty for an experiment, for now.

        class << self
          def [] s
            new s
          end
          private :new
        end  # >>

        def initialize string

          @_cached = false

          scn = Home_.lib_.string_scanner string

          sp = /[[:space:]]+/
          quot = /['"]/
          word_like = /[a-zA-Z0-9]+[^[:space:]]*/

          @_p = -> do

            scn.skip sp
            x = scn.scan quot
            if x
              self._NOT_TODAY
            end

            s = scn.scan word_like
            if s

              [ :word_like, s ]

            elsif scn.eos?

              @_p = EMPTY_P_
              NIL_

            else

              s = scn.rest
              @_p = EMPTY_P_
              [ :unknown, s ]  # meh
            end
          end
        end

        def unparsed_exists
          @_cached || _cache
          @_has_one
        end

        def head_as_is
          @_cached || _cache
          if @_has_one
            @_x
          else
            raise ::KeyError
          end
        end

        def advance_one
          @_cached = false
          _cache
          NIL_
        end

        def _cache
          @_cached && self._SANITY
          @_cached = true
          x = @_p[]
          if x
            @_has_one = true
            @_x = x
          else
            @_has_one = false
            @_x = x
          end
          NIL_
        end
      end
    end
  end
end
