module Skylab::Human

  NLP.const_get :Expression_Frame  # experiment with scoping

  class NLP::Expression_Frame

    module NLP::EN

      class Expression_Frames___::Object_and_Subject < EF_

        REQUIRED_TERMS = [ :subject_list, :subject_atom, :object ]

        OPTIONAL_TERMS = [ :negative, :implication_of_future ]

        def initialize idea

          @_do_early_list = false
          @_do_late_list = false
          @_idea = idea
          @_is_one = false
          @_is_zero = false
          @_use_plural = false
          @_VERB_ETC_TODO = nil
        end

        def express_into y

          @_downstream = y  # when you need to, spawn via dup & mutate

          case @_idea.subject_list.length

          when 0
            __zero
          when 1
            __one
          when 2
            __two
          else
            __more_than_two
          end
        end

        def __zero

          @_use_plural = true
          @_is_zero = true
          # "no characters are supported yet."
          _go
        end

        def __one

          @_do_early_list = true
          @_is_one = true
          # "the x character is not yet supported."
          _go
        end

        def __two

          @_do_early_list = true
          @_use_plural = true
          # "the x and y characters are not yet supported."
          _go
        end

        def __more_than_two

          @_do_late_list = true
          @_use_plural = true
          # "the following characters are not yet supported: a, b and c."
          _go
        end

        def _go  # for now, so many hax

          @_y = s_a = []  # spawn via dup and mutate whenever

          __express_article

          if @_do_late_list

            s_a.push 'following'

          elsif @_do_early_list

            _express_subject_list
          end

          __express_subject

          __express_verb

          if @_idea.has_implication_of_future && ! @_is_zero
            _say_yet_or_already
          end

          __express_object_into s_a

          if @_idea.has_implication_of_future && @_is_zero
            _say_yet_or_already
          end

          if @_do_late_list
            __express_late_list
          end

          a = @_y ; @_y = nil

          @_downstream << to_string_with_punctuation_hack_( a )
        end

        def __express_article

          if @_is_zero
            _say 'no'
          else
            _say 'the'
          end
        end

        def __express_late_list

          _say ':'
          _express_subject_list
        end

        def _express_subject_list

          _say EN_.oxford_comma @_idea.subject_list.to_a
        end

        def __express_subject

          prd = EN_::POS::Noun[ @_idea.subject_atom.to_s ]
          @__hax = prd
          prd << :_do_not_use_article_

          if @_use_plural
            prd << :plural
          elsif @_is_one
            prd << :singular
          end

          _say prd.to_string
        end

        def __express_verb

          pron = EN_::POS::Noun[ 'eew' ]
          pron << :third

          if @_use_plural
            pron << :plural
          else
            pron << :singular
          end
          prd = EN_::POS::Verb[ pron, __some_verb_string ]
          _say prd.to_string

          if @_idea.is_negative && ! @_is_zero  # no dbl negs
            _say 'not'
          end
          NIL_
        end

        def __some_verb_string

          if @_VERB_ETC_TODO
            self._ETC
          else
            DEFAULT_VERB_LEMMA___
          end
        end

        DEFAULT_VERB_LEMMA___ = 'be'.freeze

        def _say_yet_or_already

          if @_idea.is_negative || @_is_zero
            _say 'yet'
          else
            _say 'already'
          end
        end

        def __express_object_into s_a

          a = @_idea.object_list
          a and self._DO_ME

          _say @_idea.object_atom.to_s  # or whatever
        end

        def _say string
          @_y.push string
          NIL_
        end
      end
    end
  end
end
