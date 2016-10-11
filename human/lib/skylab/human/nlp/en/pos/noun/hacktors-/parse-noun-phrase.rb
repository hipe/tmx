module Skylab::Human

  module NLP::EN::Phrase_Structure_

    class NLP::EN::POS::Noun

      class Hacktors_::Parse_noun_phrase

        class << self

          def via_string s
            o = new
            o.__receive_string s
            o.execute
          end

          def via_parse st
            o = new
            o._receive_parse st
            o.execute
          end

          def [] s
            new( s ).execute
          end
        end  # >>

        # this is a one-off hack as a quick sketch. longterm this is certainly
        # not wheel we need to re-invent; it is just a means to an end.
        #
        # the ultimate goal of this (for now) is to parse semi-correctly
        #
        #   "content after it"
        #
        # as distinct from a parse for
        #
        #   "purple people eater"
        #
        # in the former example, the lemma of the noun-phrase is the first
        # word, in the latter it is the last.
        #
        # because the prepositions we care about fit in a very short list,
        # we can hack implement the above for our needs, as a stand-in for
        # a future we might like to have.

        def initialize
          @_pp = nil
        end

        def __receive_string s

          _st = Phrase_Structure_::Input_Adapters::Token_Stream_via_String[ s ]
          _receive_parse _st
        end

        def _receive_parse _st
          @_up = _st
          NIL_
        end

        def execute

          @_done = false
          @_leading_s_a = []

          st = @_up

          sym, s = st.current_token

          begin

            send :"__at_leading__#{ sym }__", s

            if @_done
              break
            end

            st.advance_one
            if st.unparsed_exists
              sym, s = st.current_token
              redo
            end
            break
          end while nil

          __flush
        end

        def __at_leading__word_like__ s

          pp = EN_::POS::Preposition.phrase_via_parse @_up
          if pp
            @_pp = pp
          else
            @_leading_s_a.push s
          end
          NIL_
        end

        def __flush

          s_a = @_leading_s_a
          lemma = s_a.pop

          if s_a.length.nonzero?

            adjp = EN_::Phrase_Structure::Noun_inflectee_via_word_array[ s_a ]
          end

          np = EN_::POS::Noun[ lemma ]

          if adjp
            np.prepend_adjective_phrase adjp
          end

          pp = remove_instance_variable :@_pp
          if pp
            np.append_prepositional_phrase pp
          end

          np
        end
      end
    end
  end
end
