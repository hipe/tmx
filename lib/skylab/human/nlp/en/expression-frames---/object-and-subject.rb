module Skylab::Human

  # be within this lexical scope:

  NLP.const_get :Expression_Frame

  class NLP::Expression_Frame

    # and this one:

    NLP::EN.const_get :Idiomization_

    module NLP::EN::Idiomization_

      class NLP::EN::Expression_Frames___::Object_and_Subject < EF_

        REQUIRED_TERMS = [ :subject, :object ]

        OPTIONAL_TERMS = [ :negative, :implication_of_future ]

        PRODUCES = [ :sentence_phrase ]

        def initialize idea

          si = Idiomization_::Sessions::Nounish.begin
          oi = Idiomization_::Sessions::Nounish.begin

          si.receive_list_and_atom idea.subject_list, idea.subject_atom
          oi.receive_list_and_atom idea.object_list, idea.object_atom

          np = si.noun_phrase

          vp = EN_::POS::Verb[ np, __some_verb_lemma( idea ) ]

          vp.object_noun_phrase = oi.noun_phrase

          if idea.negative || si.can_express_negativity
            __ideate_negativity_minimally oi, si, vp
          end

          if ! oi.is_adjectivial
            __inflect_object_number_with_subject_number oi, si, idea
          end

          if idea.implication_of_future
            __emphasize_contrast_with_future oi, si, vp, idea
          end

          sp = EN_::POS::Sentence[ np, vp ]

          if si.list_is_long && si.atom_was_provided && ! oi.list_was_provided
            __move_list_to_end sp
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

        def __ideate_negativity_minimally oi, si, vp

          if si.must_express_negativity
            # ok.
          elsif oi.must_express_negativity
            # ok.
          elsif si.can_express_negativity

            if si.list_was_provided
              si.noun_phrase << :plural  # "no foo was" => "no foos were"
            end
          else

            if ! oi.is_adjectivial
              oi.noun_phrase << :the_counterpart_quantity_determiner
            end

            vp.become_negative
          end
          NIL_
        end

        def __inflect_object_number_with_subject_number oi, si, idea

          if :plural == si.noun_phrase.number

            unless oi.list_was_provided
              oi.noun_phrase << :plural
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

          np = sp.noun_phrase
          listp = np.remove_adjective_phrase

          _ = EN_::Phrase_Structure::Noun_inflectee_via_string[ 'following' ]
          np.initialize_adjective_phrase _

          sp.conjunctive_tail_ = listp
          NIL_
        end

        def express_into upstream_x

          _y = @_sentence_phrase.express_words_into []

          _s = to_string_with_punctuation_hack_ _y

          upstream_x << _s
        end
      end
    end
  end
end
