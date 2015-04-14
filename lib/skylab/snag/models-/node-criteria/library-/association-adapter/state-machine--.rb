module Skylab::Snag

  module Models_::Node_Criteria

    module Library_

      class Association_Adapter::State_Machine__

        def initialize * a, & oes_p

          @on_event_selectively = oes_p
          @state, vmp, sym, vmp_, @st, ada = a

          @named_functions_ = ada.named_functions_
          @verb_lemma = ada.verb_lemma

          @did_reach_back = false

          x = _cls_for( sym ).new
          x.push vmp
          x.push vmp_
          @top_x = x
          @x = x
        end

        def execute

          if @st.unparsed_exists

            @d = @st.current_index

            begin

              _stay = send :"__#{ @state }__"
              _stay or break

              if @st.unparsed_exists
                redo
              end
              break
            end while nil
          end

          @top_x
        end

        def __new_context__  # is blue and pink or is green

          if _parse_conjunctive_token  # and / or

            if _parse_verb  # ..is

              if _parse_verb_modifier_phrase

                if @top_x.symbol == @sym

                  @state = :after_verb_phrase
                  _write_verb_modifier_phrase_to @top_x
                else
                  _ambiguous @top_x.symbol
                end

              else
                _none_and_done
              end
            elsif _parse_verb_modifier_phrase  # ..lavender

              __branch_down
            else
              _none_and_done
            end
          end
        end

        def __after_verb_phrase__  # is pink or is green

          if _parse_conjunctive_token  # .. and

            if _parse_verb  # .. is

              if _parse_verb_modifier_phrase  # .. red

                if @top_x.symbol == @sym

                  _write_verb_modifier_phrase_to @top_x
                else
                  _ambiguous  @top_x.symbol  # :+#not-covered
                end
              else
                _none_and_done
              end
            elsif _parse_verb_modifier_phrase  # .. red

              __reach_back
            else
              _none_and_done
            end
          end
        end

        def __in_verb_modifier_phrase__  # is pink or green

          if _parse_conjunctive_token  # .. and

            if _parse_verb  # .. is

              if _parse_verb_modifier_phrase  # .. red

                if @did_reach_back

                  @state = :after_verb_phrase
                  _write_verb_modifier_phrase_to @top_x
                else
                  __context_pop
                end
              else
                _none_and_done
              end
            elsif _parse_verb_modifier_phrase  # ..blue

              if @x.symbol == @sym

                _write_verb_modifier_phrase_to @x
              else
                _ambiguous @x.symbol
              end
            else
              _none_and_done
            end
          end
        end

        def _write_verb_modifier_phrase_to a

          @d = @st.current_index
          a.push @vmp
          KEEP_PARSING_
        end

        def __context_pop

          new = _cls_for( @sym ).new
          new.push @top_x
          new.push @vmp

          @d = @st.current_index
          @state = :new_context
          @top_x = new
          @x = @vmp

          KEEP_PARSING_
        end

        def __reach_back

          @did_reach_back = true

          new = _cls_for( @sym ).new

          guy = @top_x.replace_last_with_ new
          new.push guy
          new.push @vmp

          @d = @st.current_index
          @state = :in_verb_modifier_phrase
          @x = new

          KEEP_PARSING_
        end

        def __branch_down

          new = _cls_for( @sym ).new
          new.push @x
          new.push @vmp

          @d = @st.current_index
          @state = :in_verb_modifier_phrase
          @top_x.replace_last_with_ new
          @x = new

          KEEP_PARSING_
        end

        def _parse_conjunctive_token

          sym = parse_a_conjunctive_token_ @st
          if sym
            @sym = sym
            KEEP_PARSING_
          end
        end

        def _parse_verb

          d = scan_the_verb_token_ @st
          if d
            KEEP_PARSING_
          end
        end

        def _parse_verb_modifier_phrase

          on = parse_a_verb_modifier_phrase_ @st
          if on
            @vmp = on
            KEEP_PARSING_
          end
        end

        def _none_and_done

          @st.current_index = @d
          DID_NOT_PARSE_
        end

        def _cls_for and_or_or_sym

          Library_::Models_.const_get( AND_OR_OR_CONST_[ and_or_or_sym ], false )
        end

        def _ambiguous sym

          @on_event_selectively.call :error, :parse_error, :ambiguity do

            Callback_::Event.inline_not_OK_with :ambiguous,
                :x, @sym,
                :symbol, sym,
                :error_category, :argument_error do | y, o |

              y << "#{ ick o.x.id2name } #{
               }is ambiguous here because of a previous #{
                }#{ val o.symbol.id2name }"
            end
          end

          @top_x = UNABLE_
          _none_and_done
        end

        include Association_Parse_Functions_

        AND_OR_OR_CONST_ = { and: :And, or: :Or }
      end
    end
  end
end
