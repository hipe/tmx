module Skylab::Snag

  class Models_::Criteria

    module Library_

      class Association_Adapter::State_Machine__

        # (this was a mentor to #[#ba-044.2]. student has surpassed teacher.)

        def initialize * a, & oes_p

          @on_event_selectively = oes_p
          @state, vmp, sym, vmp_, @in_st, @grammatical_context, @ada = a

          @named_functions_ = @ada.named_functions_
          @verb_s_a = @ada.verb_lemma_and_phrase_head_s_a

          @did_reach_back = false

          x = _cls_for( sym ).new
          x.push vmp
          x.push vmp_
          @top_x = x
          @x = x
        end

        def execute

          if @in_st.unparsed_exists

            @d = @in_st.current_index

            begin

              _stay = send :"__#{ @state }__"
              _stay or break

              if @in_st.unparsed_exists
                redo
              end
              break
            end while nil
          end

          @top_x
        end

        def __new_context__  # is blue and pink or is green

          if _parse_conjunctive_token  # and / or

            if _parse_verb  # ..is  :+#one

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

        # the below is begging for [#005] cleanup

        def __after_verb_phrase__  # is pink or is green

          if _parse_conjunctive_token  # .. and

            if _parse_verb  # .. is  :+#one

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

            if _parse_verb  # .. is  # :+#one

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

          @d = @in_st.current_index
          a.push @vmp
          KEEP_PARSING_
        end

        def __context_pop

          new = _cls_for( @sym ).new
          new.push @top_x
          new.push @vmp

          @d = @in_st.current_index
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

          @d = @in_st.current_index
          @state = :in_verb_modifier_phrase
          @x = new

          KEEP_PARSING_
        end

        def __branch_down

          new = _cls_for( @sym ).new
          new.push @x
          new.push @vmp

          @d = @in_st.current_index
          @state = :in_verb_modifier_phrase
          @top_x.replace_last_with_ new
          @x = new

          KEEP_PARSING_
        end

        def _parse_conjunctive_token

          sym = Parse_a_conjunction_[ @in_st ]
          if sym
            @sym = sym
            KEEP_PARSING_
          end
        end

        def _parse_verb & x_p

          _did = @ada.scan_the_verb_phrase_head_out_of_under_(
            @in_st, @grammatical_context, & x_p )

          if _did
            KEEP_PARSING_
          end
        end

        def _parse_verb_modifier_phrase

          on = @ada.verb_modifier_phrase_via_input_stream_(
            @in_st, & @on_event_selectively )

          if on
            @vmp = on
            KEEP_PARSING_
          end
        end

        def _none_and_done

          @in_st.current_index = @d
          DID_NOT_PARSE_
        end

        def _cls_for and_or_or_sym

          Library_::Models_.class_via_symbol and_or_or_sym
        end

        def _ambiguous sym

          @on_event_selectively.call :error, :parse_error, :ambiguity do

            Common_::Event.inline_not_OK_with :ambiguous,
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
      end
    end
  end
end
