module Skylab::Human

  module NLP::EN

    class Magnetics::Expression_via_Idea_with_Object_and_Subject <
        Home_::ExpressionPipeline_::Expression

      # referenced by magic only (near `_via_Idea_with_`).

      # ->
        REQUIRED_TERMS = [ :subject, :object ]

        OPTIONAL_TERMS = [ :negative, :later_is_expected ]

        PRODUCES = [ :sentence_phrase ]

        def initialize idea

          si = Magnetics::NounPhraseish_via_Components.begin

          si.receive_count_and_list_and_atom( *
            idea.to_subject_count_and_list_and_atom )

          _is_the_nothing_case = si.count_was_provided &&
            si.can_express_negativity

          if _is_the_nothing_case

            __will_express_negative_existence si

          else
            __will_express_something si, idea
          end
        end

        def __will_express_negative_existence si

          np = si.noun_phrase

          vp = EN_::POS::Verb[ np, 'be' ]

          sp = EN_::POS::Sentence[ np, vp ]

          sp.initialize_adverbial_inversion 'there'

          @_sentence_phrase = sp
        end

        def __will_express_something si, idea

          oi = Magnetics::NounPhraseish_via_Components.begin

          oi.receive_count_and_list_and_atom( *
            idea.to_object_count_and_list_and_atom )

          np = si.noun_phrase

          vp = EN_::POS::Verb[ np, __some_verb_lemma( idea ) ]

          vp.object_noun_phrase = oi.noun_phrase

          @_do_crazy_thing = false

          if idea.more_is_expected

            __more_is_expected si, idea
          end

          if idea.negative || si.can_express_negativity

            __ideate_negativity_minimally oi, si, vp, idea
          end

          __inflect_object_number_with_subject_number oi, si, idea

          if idea.later_is_expected
            __emphasize_contrast_with_future oi, si, vp, idea
          end

          sp = EN_::POS::Sentence[ np, vp ]

          if si.list_is_long && si.atom_was_provided && ! oi.list_was_provided
            __move_list_to_end sp
          end

          if @_do_crazy_thing
            Self_::Some_of_many_sp_split___[ sp, si ]
          end

          @_sentence_phrase = sp
        end

        def __some_verb_lemma idea
          va = idea.verb_argument
          if va
            lemma = va.lemma_string
          end
          lemma || DEFAULT_VERB_LEMMA___
        end

        DEFAULT_VERB_LEMMA___ = 'be'

        def __more_is_expected si, idea

          # super crazy

          if idea.negative && si.quad_count.is_more_than_one
            @_do_crazy_thing = true
          else
            __use_only si
          end
        end

        def __use_only si

          np = si.noun_phrase
          ph = _phrase_via_non_inflecting_lemma 'only'

          if si.count_was_provided &&
            si.quad_count.is_one &&
            :definite == np.article.intern

              # don't say "the 1 only"

            np.adjective_phrase.replace_first_item ph

          else

            np.prepend_adjective_phrase ph

          end
          NIL_
        end

        def __ideate_negativity_minimally oi, si, vp, idea

          if si.must_express_negativity
            # ok.
          elsif oi.must_express_negativity
            # ok.
          elsif si.can_express_negativity

            if si.list_was_provided
              si.noun_phrase << :plural  # "no foo was" => "no foos were"
            end
          else
            __any_or_no oi, si, vp, idea
          end
        end

        def __any_or_no oi, si, vp, idea

          # we *must* express the negativity. exactly how we do this is
          # largely a stylistic and feels nearly arbitrary. (comment out
          # various parts to see the difference against test). here we
          # debate beween the default, more natural sounding form of e.g
          #
          #    e.g "i don't have any things"
          #
          # vs. the slightly more formal
          #
          #    e.g "i have no things"
          #
          # whether we do the "any" or the "no" form is the focus here:

          yes = true  # use the "any" form as a default

          if idea.more_is_expected  # otherwise busy
            yes = false
          end

          if si.count_was_provided  # otherwise busy ..

            if si.quad_count.is_more_than_one
              yes = false
            end
          end

          if yes

            if ! oi.is_adjectivial
              oi.noun_phrase << :the_counterpart_quantity_determiner  # 'any'
            end

            vp.become_negative

          else

            if ! oi.is_adjectivial
              oi.noun_phrase << :the_negative_determiner
            end
          end
          NIL_
        end

        def __inflect_object_number_with_subject_number oi, si, idea

          # for now we assume that the received form is singular (of object)

          if :plural == si.noun_phrase.number

            __antecedent_is_plural oi
          end
          NIL_
        end

        def __antecedent_is_plural oi

          np = oi.noun_phrase
          pp = np.prepositional_phrases

          # (make these easy to de-activate, for demonstration purposes:)

          yes = true

          if oi.is_adjectivial
            yes = false
          end

          if oi.list_was_provided
            yes = false
          end

          if np.lexeme.is_mass_noun
            yes = false
          end

          if yes
            np << :plural
          end

          if pp

            st = pp.to_stream_of_pronouns
            if st
              st.each do | np_ |
                np_ << :plural
              end
            end
          end
          NIL_
        end

        def __emphasize_contrast_with_future oi, si, vp, idea

          is_negative = if idea.negative
            true
          elsif si.can_express_negativity
            true
          end

          lemma = is_negative ? 'yet' : 'already'

          do_middle = if vp.is_negative
            true  # ok without
          elsif ! is_negative
            true
          end

          if do_middle
            vp.initialize_middle_adverb_via_lemma lemma
          else
            vp.initialize_late_adverb_via_lemma lemma
          end

          NIL_
        end

        def __move_list_to_end sp

          _ = _phrase_via_non_inflecting_lemma 'following'

          _listp = sp.noun_phrase.adjective_phrase.replace_only_item _

          sp.conjunctive_tail_ = _listp

          NIL_
        end

        def _phrase_via_non_inflecting_lemma s
          EN_::Phrase_Structure::Noun_inflectee_via_string[ s ]
        end

        def express_into upstream_x

          _y = @_sentence_phrase.express_words_into []

          _s = to_string_with_punctuation_hack_ _y

          upstream_x << _s
        end
      # -

      Self_ = self
    end
  end
end
