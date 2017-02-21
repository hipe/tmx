module Skylab::Snag

  class Models_::Criteria

    module Library_

      class DomainAdapter

        class Magnetics_::CriteriaInterpretation_via_Arguments

          # ( local name convention: `resolve` ::= `interpret` `synthesize` )

          def initialize s_a, domain, & oes_p

            @domain = domain
            @in_st = Home_.lib_.parse_lib::Input_Streams_::Array.new s_a
            @on_event_selectively = oes_p
          end

          def execute

            ok = __resolve_any_article_and_subject_and_any_conjunction
            ok &&= __resolve_tree_of_predicates
            ok &&= __confirm_that_all_is_parsed
            ok && @tree_of_predicates
          end

          def __resolve_any_article_and_subject_and_any_conjunction

            art = Any_article__[ @in_st ]
            if art
              send :"__resolve_subj_and_conj_for__#{ art.name_symbol }__"
            else
              __resolve_subj_and_conj_for_indefinite_plural
            end
          end

          Any_article__ = Build_simple_word_parser_.call(
            :indefinite_article, :regex, /\Aan?\z/,
            :definite_article, :keyword, 'the' )

          # "a thing that.." (one day we might use this for etc)

          def __resolve_subj_and_conj_for__indefinite_article__

            _ok = _interpret :model_reflection, :singular_model_name

            _ok && Keyword_that__[ @in_st, & @on_event_selectively ]
          end

          # "the thing [is].."  (conditional expressions look best in this form)

          def __resolve_subj_and_conj_for__definite_article__

            _interpret :model_reflection, :singular_model_name
          end

          # "things that .."  ("queries" look best in this form)

          def __resolve_subj_and_conj_for_indefinite_plural

            _ok = _interpret :model_reflection, :plural_model_name

            _ok && Keyword_that__[ @in_st, & @on_event_selectively ]
          end

          Keyword_that__ = Build_simple_word_parser_[
            :_modifier_conjunction_, :keyword, 'that' ]

          def __resolve_tree_of_predicates  # this is an attempt at [#005] a model solution for this

            ok = _interpret_one_verb_phrase( & @on_event_selectively )
            ok && begin
              ok_ = __interpret_first_AND_or_OR_verb_phrase
              while ok_
                ok_ = __interpret_subsequent_particular_AND_or_OR_verb_phase
              end
              ok && __synthesize_tree_of_predicates
            end
          end

          def __interpret_first_AND_or_OR_verb_phrase

            _interpret_first_AND_or_OR_thing do | sym |
              @verbs_conjunction = sym
              _interpret_one_verb_phrase
            end
          end

          def _interpret_one_verb_phrase & x_p

            _ok = __resolve_possible_assoc_adapters_against_head_verb( & x_p )
            _ok &&= __via_assoc_adapters_resolve_tree_of_predicate_tails( & x_p )
          end

          def __resolve_possible_assoc_adapters_against_head_verb & x_p

            x_a = []
            send :"__edit_grammatical_context_for__#{ @used_form_symbol }__", x_a
            @g_ctxt = Library_::Grammatical_Context_.new_via_iambic x_a

            error_cache = nil
            x_p_ = if x_p
              -> * i_a, & ev_p do
                error_cache ||= []
                error_cache.push i_a, ev_p
                UNABLE_
              end
            else
              NIL_
            end

            cand_a = @domain.possible_assoc_adptrs_through_longest_head_verb_(
                @in_st,
                @g_ctxt,
                @model_reflection.identifier, & x_p_ )

            if cand_a.length.zero?
              if x_p_
                x_p_.call :error, :expecting do
                  Build_aggregate_event_[ error_cache ]
                end
              end
              UNABLE_
            else

              @in_st.current_index = cand_a.fetch( 0 ).distance

              @assoc_ada_a = cand_a.map( & :adapter )

              ACHIEVED_
            end
          end

          def __edit_grammatical_context_for__plural_model_name__ x_a
            x_a.push :subject_number, :plural
          end

          def __edit_grammatical_context_for__singular_model_name__ x_a
            x_a.push :subject_number, :singular
          end

          def __via_assoc_adapters_resolve_tree_of_predicate_tails

            @pred_tail_a = []

            ok = _interpret_one_predicate_tail
            if ok
              ok_ = __interpret_first_AND_or_OR_predicate_tail
              while ok_
                ok_ = __interpret_subsequent_particular_AND_or_OR_predicate_tail
              end
              ok &&= __synthesize_predicate_tail_tree
            end
            ok
          end

          def __interpret_first_AND_or_OR_predicate_tail

            _interpret_first_AND_or_OR_thing do | sym |

              @pred_tail_conjunction = sym
              _interpret_one_predicate_tail
            end
          end

          def _interpret_first_AND_or_OR_thing

            d = @in_st.current_index
            sym = Parse_a_conjunction_[ @in_st ]
            ok = if sym
              yield sym
            end
            if ! ok
              @in_st.current_index = d  # walk back to before the conjunction
            end
            ok
          end

          def __interpret_subsequent_particular_AND_or_OR_predicate_tail

            d = @in_st.current_index
            sym = Parse_a_conjunction_[ @in_st ]
            ok = if sym

              winner = _parse_one_predicate_tail
              if winner

                if @pred_tail_conjunction == sym
                  @pred_tail_a.push winner.output_node
                  ACHIEVED_
                else
                  self._UNRECOVERABLE_AMBIGUIITY_YAY
                end
              end
            end
            if ! ok
              @in_st.current_index = d
            end
            ok
          end

          def __interpret_subsequent_particular_AND_or_OR_verb_phase

            if @in_st.unparsed_exists
              self._ABSTRACT_from_the_other_one  # which is [#005]
            else

              DID_NOT_PARSE_
            end
          end

          def _interpret_one_predicate_tail

            winner = _parse_one_predicate_tail
            winner and begin

              @pred_tail_a.push winner.output_node
              ACHIEVED_
            end
          end

          def _parse_one_predicate_tail

            _f_st = Common_::Stream.via_nonsparse_array @assoc_ada_a

            winner = Parse_highest_scoring_candidate_.call(
                @in_st,
                _f_st,
                nil  # :+#one
            ) do | in_st, f, & x_p_ |

              f.interpret_verb_phrase_tail_out_of_under_(
                in_st, @g_ctxt, & x_p_ )
            end

            winner and begin
              winner.distance = nil
              winner
            end
          end

          def __synthesize_predicate_tail_tree

            _x = if 1 == @pred_tail_a.length
              @pred_tail_a.fetch 0
            else
              _cls = Library_::Models_.class_via_symbol @pred_tail_conjunction
              _cls.new @pred_tail_a
            end

            @pred_tail_a = nil

            @pred_tail_trees ||= []
            @pred_tail_trees.push _x

            ACHIEVED_
          end

          def __synthesize_tree_of_predicates

            _top_x = if 1 == @pred_tail_trees.length
              @pred_tail_trees.fetch 0
            else
              _cls = Library_::Models_.class_via_symbol @verbs_conjunction
              _cls.new @pred_tail_trees
            end

            @pred_tail_trees = nil

            @tree_of_predicates = Common_::Pair.via_value_and_name(
              _top_x,
              @model_reflection.identifier )

            ACHIEVED_
          end

          def __confirm_that_all_is_parsed

            if @in_st.no_unparsed_exists
              ACHIEVED_
            else
              self._THIS
            end
          end

          # ~ abstraction candidates

          def _interpret target_sym, * surface_forms

            cached_errors = nil
            did_find = UNABLE_

            surface_forms.each do | surface_form |

              _method = :"interpret__#{ target_sym }__via__#{ surface_form }__"

              x = @domain.send _method, @in_st do | * i_a, & ev_p |
                if :error == i_a.first
                  cached_errors ||= []
                  cached_errors.push [ i_a, ev_p ]
                  NIL_

                end
              end

              x or next

              did_find = ACHIEVED_
              instance_variable_set :"@#{ target_sym }", x
              @used_form_symbol = surface_form
              break
            end

            if ! did_find
              _add_cached_errors cached_errors
            end

            did_find
          end

        end
      end
    end
  end
end
