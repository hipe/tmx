module Skylab::Human

  module NLP::EN::Idiomization_

    class Sessions::Nounish

      # this is divorced from conception of subject vs object. its purpose
      # is to produce a starter noun-phrase given permutations of atom, list
      # and negatively, one that may be mutated further by a coodinator.
      #
      # it is a session and not an actor because it will keep pertinent
      # metadata around to be used by the coordinator (e.g an "expression
      # frame") for final expression.

      class << self
        alias_method :begin, :new
        private :new
      end

      attr_reader :atom_was_provided, :count_was_provided, :list_was_provided

      attr_reader :is_adjectivial

      def receive_count_and_list_and_atom co, li, at

        @_np = nil

        if at
          __receive_atom_and co, li, at
        elsif li
          co and self._LOGIC_HOLE
          send :"__when__#{ _eek li }__list_only"
        elsif co
          self._TODO__when_count_only
        else
          self._TODO__when_no_arguments
        end
        NIL_
      end

      def __receive_atom_and co, li, at

        @atom_was_provided = true
        @_atom_arg = at
        s = at.to_string
        if s.include? SPACE_

          @_np = EN_::POS::Noun.phrase_via_string s
        else
          @_lemma = s
        end

        if at.is_adjectivial
          @is_adjectivial = true
          @_definity = :_do_not_use_article_
        end

        if li
          send :"__when_atom_and__#{ _eek li }__list"
        else

          if co
            @_count_arg = co
            @count_was_provided = true
            send :"__when_atom_and__#{ co.quad_count_category }__count"
          else
            __when_atom_only
          end
        end
      end

      def _eek li
        @_list_arg = li
        @list_was_provided = true
        li.quad_count_category
      end

      attr_reader :can_express_negativity,
        :must_express_negativity

      def quad_count
        NLP::Expression_Frame::Models::Quad_Count.fetch @_quad_count_category
      end

      def __when__none__list_only  # see previous method comment

        @must_express_negativity = true

        @_definity ||= :_do_not_use_article_
        @_lemma = 'nothing'
        @_number_exponent = :singular  # do NOT infer number from qqc here!
        @_quad_count_category = :none
        _init_noun_phrase
      end

      def __when_atom_only

        @_definity ||= :_do_not_use_article_  # see below
        @_quad_count_category = :one
        _init_noun_phrase
        np = @noun_phrase
        if ! @_atom_arg.is_adjectivial
          np.use_indefinite_article_if_appropriate
        end
        NIL_
      end

      def __when__one__list_only

        @_definity ||= :_do_not_use_article_
        @_lemma = @_list_arg.to_array.fetch 0
        @_quad_count_category = :one
        _init_noun_phrase
      end

      def __when__two__list_only

        @_definity ||= :_do_not_use_article_
        @_lemma = nil
        @_quad_count_category = :two
        _init_noun_phrase_plus_adjective_list
      end

      attr_reader :list_is_long

      def __when__more_than_two__list_only

        @list_is_long = true

        @_definity ||= :_do_not_use_article_
        @_lemma = nil
        @_quad_count_category = :more_than_two
        _init_noun_phrase_plus_adjective_list
      end

      def __when_atom_and__none__list

        __a_singular_empty_set
      end

      def __when_atom_and__one__list

        @_definity ||= :definite
        @_quad_count_category = :one
        _init_noun_phrase_plus_adjective_list
      end

      def __when_atom_and__two__list

        @_definity ||= :definite
        @_quad_count_category = :two
        _init_noun_phrase_plus_adjective_list
      end

      def __when_atom_and__more_than_two__list

        @list_is_long = true

        @_definity ||= :definite
        @_quad_count_category = :more_than_two
        _init_noun_phrase_plus_adjective_list
      end

      def _init_noun_phrase_plus_adjective_list

        _init_noun_phrase
        _ = Models::Portable_List_Phrase.new_via_list_arg @_list_arg
        @noun_phrase.prepend_adjective_phrase _
        NIL_
      end

      # ~ count

      def __when_atom_and__none__count

        __a_plural_empty_set
      end

      def __when_atom_and__one__count

        @_definity ||= :definite
        @_quad_count_category = :one
        _init_noun_phrase_plus_count_adjective
      end

      def __when_atom_and__two__count

        @_definity ||= :definite
        @_quad_count_category = :two
        _init_noun_phrase_plus_count_adjective
      end

      def __when_atom_and__more_than_two__count

        @_definity ||= :definite
        @_quad_count_category = :more_than_two
        _init_noun_phrase_plus_count_adjective
      end

      def _init_noun_phrase_plus_count_adjective

        _init_noun_phrase

        _ = Home_.lib_.basic::Number::As_noun_inflectee[ @_count_arg.to_integer ]

        @noun_phrase.prepend_adjective_phrase _

        NIL_
      end

      def __DETACHED_init_noun_phrase_plus_quantity_hack s  # e.g 'both'

        _init_noun_phrase
        np = @noun_phrase
        np.quantity_hack_ = EN_::Phrase_Structure.noun_inflectee do | y, _ |
          y << s << 'of'
        end
        NIL_
      end

      # ~ end count

      def __a_singular_empty_set

        _common_empty_set
        @_number_exponent = :singular
        _init_noun_phrase
      end

      def __a_plural_empty_set

        _common_empty_set
        @_number_exponent = :plural
        _init_noun_phrase
      end

      def _common_empty_set  # compare to where 'nothing' is used

        @can_express_negativity = true
        @_definity ||= :the_negative_determiner
        @_quad_count_category = :none
        NIL_
      end

      attr_reader :noun_phrase

      def _init_noun_phrase

        @_number_exponent ||= ( :one == @_quad_count_category ? :singular : :plural )

        dexp = remove_instance_variable :@_definity
        nexp = remove_instance_variable :@_number_exponent

        if instance_variable_defined? :@_lemma
          np = EN_::POS::Noun[ remove_instance_variable( :@_lemma ) ]
        else
          np = remove_instance_variable :@_np
        end

        # here for now, might need to move it up ..

        np << :third  # ( for now never "you" or "I" )

        if ! np.pronoun_is_active

          # currently, asking the production to inflect using any definity
          # exponent will de-actiate any activated pronoun (by design).
          # if client expressed the pronoun gateway lemma (that is, "it"),
          # do not add our definity to it for this reason.

          np << dexp
        end

        np << nexp  # regardless of all above, always inflect by our number

        @noun_phrase = np
        NIL_
      end
    end
  end
end
