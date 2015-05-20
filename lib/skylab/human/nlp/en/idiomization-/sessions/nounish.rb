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

      attr_reader :atom_was_provided, :is_adjectivial, :list_was_provided

      def receive_list_and_atom li, at

        eek = -> do
          @_list_arg = li
          @list_was_provided = true
          li.quad_count_category
        end

        if at
          @_atom_arg = at
          @_lemma = at.to_string
          @atom_was_provided = true

          if at.is_adjectivial
            @is_adjectivial = true
            @_definity = :_do_not_use_article_
          end

          if li
            send :"__when_atom_and__#{ eek[] }__list"
          else
            __when_atom_only
          end
        elsif li
          send :"__when__#{ eek[] }__list_only"
        else
          self._TODO__when_neither
        end
        NIL_
      end

      attr_reader :can_express_negativity,
        :must_express_negativity

      def __when__none__list_only

        @must_express_negativity = true

        @_definity ||= :_do_not_use_article_
        @_lemma = 'nothing'
        @_number_exponent = :singular
        _init_noun_phrase
      end

      def __when_atom_only

        @_definity ||= :indefinite
        @_number_exponent = :singular
        _init_noun_phrase
      end

      def __when__one__list_only

        @_definity ||= :_do_not_use_article_
        @_lemma = @_list_arg.to_array.fetch 0
        @_number_exponent = :singular
        _init_noun_phrase
      end

      def __when__two__list_only

        @_definity ||= :_do_not_use_article_
        @_lemma = nil
        @_number_exponent = :plural
        _init_noun_phrase_plus_adjective_list
      end

      attr_reader :list_is_long

      def __when__more_than_two__list_only

        @list_is_long = true

        @_definity ||= :_do_not_use_article_
        @_lemma = nil
        @_number_exponent = :plural
        _init_noun_phrase_plus_adjective_list
      end

      def __when_atom_and__none__list

        @can_express_negativity = true

        @_definity ||= :the_negative_determiner
        @_number_exponent = :singular
        _init_noun_phrase
      end

      def __when_atom_and__one__list

        @_definity ||= :definite
        @_number_exponent = :singular
        _init_noun_phrase_plus_adjective_list
      end

      def __when_atom_and__two__list

        @_definity ||= :definite
        @_number_exponent = :plural
        _init_noun_phrase_plus_adjective_list
      end

      def __when_atom_and__more_than_two__list

        @list_is_long = true

        @_definity ||= :definite
        @_number_exponent = :plural
        _init_noun_phrase_plus_adjective_list
      end

      def _init_noun_phrase_plus_adjective_list

        _init_noun_phrase
        _ = Models::Portable_List_Phrase.new @_list_arg
        @noun_phrase.initialize_adjective_phrase _
        NIL_
      end

      attr_reader :noun_phrase

      def _init_noun_phrase

        np = EN_::POS::Noun[ remove_instance_variable( :@_lemma ) ]

        np << remove_instance_variable( :@_definity ) <<
              remove_instance_variable( :@_number_exponent ) <<
              :third  # we are never *yet* talking about "I", "you" or "we"

        @noun_phrase = np
        NIL_
      end
    end
  end
end
