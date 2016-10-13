module Skylab::Snag

  class Models_::Criteria

    module Library_

      class Association_Adapter < Common_Adapter_

        Attributes_actor_.call( self,
          verb_lemma_and_phrase_head_s_a: nil,
        )

        attr_reader :verb_lemma_and_phrase_head_s_a

        def initialize
          @model_identifier = nil
        end

      private

        def named_functions=

          bx = Common_::Box.new
          st = polymorphic_upstream
          name_sym = st.gets_one
          func_sym = st.gets_one
          begin

            st_ = if :sequence == func_sym  # we change the syntax, experimentally
              _a = st.gets_one
              _a_= [ :functions, * _a ]
              Common_::Polymorphic_Stream.via_array _a_
            else
              st
            end

            _cls = Parse__.function func_sym

            _f = _cls.new_via_polymorphic_stream_passively st_

            bx.add name_sym, _f

            st.no_unparsed_exists and break
            name_sym = st.gets_one
            func_sym = st.gets_one
            redo
          end while nil

          @named_functions_ = bx

          KEEP_PARSING_
        end

        def verb_lemma=
          @verb_lemma_and_phrase_head_s_a = [ gets_one_polymorphic_value ]
          KEEP_PARSING_
        end

      public

        def interpret_out_of_under_ in_st, g_ctxt, & x_p

          if in_st.unparsed_exists

            d = in_st.current_index

            _did = scan_the_verb_phrase_head_out_of_under_ in_st, g_ctxt # :+#one , & x_p

            if _did  # is

              x = interpret_verb_phrase_tail_out_of_under_ in_st, g_ctxt, & x_p

              if ! x
                in_st.current_index = d
              end

            end  # «bleats»
          end
          x
        end

        def interpret_verb_phrase_tail_out_of_under_ in_st, g_ctxt, & x_p

          # spaghetti peek quite a bit before firing up a state machine
          # (this is a primordial precursor to [#005] this one pattern, and could be tightened up)

          if in_st.unparsed_exists

            d = in_st.current_index
            vmp = verb_modifier_phrase_via_input_stream_ in_st

            if vmp  # is pink

              d = in_st.current_index

              sym = Parse_a_conjunction_[ in_st ]

              if sym  # is pink or

                # #open [#013] the below is probably an overreach - detecting
                # a re-statement of the verb phrase head (even as it relates
                # to this adapter) is probably out of scope for the adapter
                # here, but rather it is something for some parent node to do
                # but let's wait for [#005]

                d_ = scan_the_verb_phrase_head_out_of_under_ in_st, g_ctxt #, & x_p  #:+#one

                vmp_ = verb_modifier_phrase_via_input_stream_ in_st

                if d_  # is pink or is

                  if vmp_  # is pink or is green

                    x = __run_against_state_machine( :after_verb_phrase,
                      vmp, sym, vmp_, in_st, g_ctxt, self, & x_p )

                  else # is pink «or is foo»
                    in_st.current_index = d
                    x = vmp
                  end
                else

                  if vmp_  # is pink or green

                    x = __run_against_state_machine( :in_verb_modifier_phrase,
                      vmp, sym, vmp_, in_st, g_ctxt, self, & x_p )

                  else  # is pink «or bleats»
                    in_st.current_index = d
                    x = vmp
                  end
                end

              else  # is pink «gazoink»
                x = vmp
              end

            else  # is «foo»
              in_st.current_index = d
            end
          end
          x
        end

        def interpret_verb_phrase_head_out_of_under_ in_st, g_ctxt, & x_p

          _yes = scan_the_verb_phrase_head_out_of_under_ in_st, g_ctxt, & x_p
          if _yes
            self
          end
        end

        def scan_the_verb_phrase_head_out_of_under_ in_st, g_ctxt, & x_p

          send :"__scan_the_verb_phrase_head_for__#{
            g_ctxt.subject_number }__via_input_stream", in_st, & x_p
        end

        def __scan_the_verb_phrase_head_for__singular__via_input_stream in_st, & x_p

          @___verb_head_string_array_for_singular ||=
            __build_verb_head_string_array_for_singular

          Parse_static_sequence_[
            in_st, @___verb_head_string_array_for_singular, & x_p ]
        end

        def __scan_the_verb_phrase_head_for__plural__via_input_stream in_st, & x_p

          @___verb_head_string_array_for_plural ||=
            __build_verb_head_string_array_for_plural

          Parse_static_sequence_[
            in_st, @___verb_head_string_array_for_plural, & x_p ]
        end

        def __build_verb_head_string_array_for_singular

          _build_verb_head_string_array_for do | adapter |

            adapter.singular_third_present
          end
        end

        def __build_verb_head_string_array_for_plural

          _build_verb_head_string_array_for do | adapter |

            adapter.plural_third_present
          end
        end

        def _build_verb_head_string_array_for

          s_a = @verb_lemma_and_phrase_head_s_a

          s = s_a.fetch 0

          adapter = Home_.lib_.NLP::EN::POS::Verb[ s ]

          if adapter.lexeme.is_regular
            self._SANITY_we_almost_always_use_irregulr_verb_like_have_and_be
          end

          s_a_ = s_a.dup
          s_a_[ 0 ] = yield adapter
          s_a_
        end

        def verb_modifier_phrase_via_input_stream_ in_st, & x_p

          Parse_first_match_via_box_[
            in_st,
            @named_functions_,
            @model_identifier,
            & x_p ]
        end

        attr_reader :model_identifier

        def receive_model_identifier_ x
          @model_identifier = x
        end

        def __run_against_state_machine * a, & x_p

          Here___::State_Machine__.new( * a, & x_p ).execute
        end

        attr_reader :named_functions_

        Autoloader_[ self ]

        Here___ = self
        Parse__ = LIB_.parse_lib
      end
    end
  end
end
