module Skylab::Human

  module NLP::EN::Sexp

    class Expression_Sessions::Nounish  # actually noun phraseish

      # (NOTE: we have *begun* to retrofit this into [#049] for now the two
      # are grafted together into one file without being integrated at all..)

      # this is divorced from conception of subject vs object. its purpose
      # is to produce a starter noun-phrase given permutations of atom, list
      # and negatively, one that may be mutated further by a coordinator.
      #
      # it is a session and not an actor because it will keep pertinent
      # metadata around to be used by the coordinator (e.g an "expression
      # frame") for final expression.

      class << self

        def interpret_component host_st, asc
          x = host_st.gets_one
          if x.respond_to? :ascii_only?
            Word_as_Nounish_Expression___.new x, asc
          else
            Here_.expression_via_these_ x, asc
          end
        end

        def interpret_component_with_own_stream_ st, asc
          Phraseish_Redux___.new st, asc
        end

        def expression_via_sexp_stream_ st  # #test-only
          Phraseish_Redux___.new st, nil
        end

        alias_method :begin, :new
        private :new
      end  # >>

    # == begin redux

    Redux_Abstract_Base = ::Class.new  # abstract

    class Word_as_Nounish_Expression___ < Redux_Abstract_Base

      def initialize s, asc
        @__word = s
        super asc
      end

      def _aggregate_ exp
        if exp._is_mutable_list_
          self._FUN_read_this
          # make sure to give the outside expression a chance to reject the
          # aggregation if for example the aggregation category is wrong
        else
          Siblings_::List.via_(
            [ self, exp ],
            :association_symbol, @association_symbol_,
          )
        end
      end

      def express_into_under y, _expage
        y << @__word
      end

      def _can_aggregate_
        true
      end
    end

    class Phraseish_Redux___ < Redux_Abstract_Base

      COMPONENTS = Attributes_[

        lemma: [ :_atomic_, :ivar, :@lemma_symbol,
                 :custom_interpreter_method_of, :__interpret_lemma ],

        modifier_word_list: [ :component, :_read ],

        proper_noun: [ :custom_interpreter_method, :_referrant_, :_read ],

        suffixed_proper_constituency: [ :component, :_read, ],

        suffixed_modifier_phrase: [ :component, :_read ],
      ]

      attr_reader( * COMPONENTS.symbols( :_read ) )

      def initialize st, asc

        @lemma_symbol = nil
        ok = COMPONENTS.init_via_stream self, st
        ok or fail
        @suffixed_proper_constituency ||= Natural_defaults___[]
        super asc
      end

      def __interpret_lemma st  # whether lemmata are symbols or strings is in transition
        x = st.gets_one
        if x.respond_to? :ascii_only?
          x = x.intern
        end
        @lemma_symbol = x
        KEEP_PARSING_
      end

      def __modifier_word_list__component_association
        Siblings_::WordList
      end

      def proper_noun=

        # this is just a plain old alias to the other,
        # but it makes for more readable sexp's

        _atr = COMPONENTS.attribute :suffixed_proper_constituency
        _atr.write self, @_polymorphic_upstream_
      end

      def __suffixed_modifier_phrase__component_association
        EN_::Sexp::AnyExpression
      end

      def __suffixed_proper_constituency__component_association
        Siblings_::Listifiable
      end

      # --

      def express_into_under y, expag

        # -- this won't stay here..  #open [#057]

        sr = nil  # space is required
        space_if_necessary = -> do
          if sr
            y << SPACE_
          else
            sr = true
          end
        end

        # --

        wl = self.modifier_word_list
        if wl
          wl.express_into_under y, expag
          sr = true
        end

        if @lemma_symbol
          space_if_necessary[]
          ___express_inflected_lemma_into y
        end

        co = @suffixed_proper_constituency
        if co.has_content_
          space_if_necessary[]
          co.express_into_under y, expag
        end

        mp = self.suffixed_modifier_phrase
        if mp
          space_if_necessary[]
          mp.express_into_under y, expag
        end

        y
      end

      def ___express_inflected_lemma_into y

        _m = number

        _hi = EN_::POS::Noun[ @lemma_symbol.id2name ]

        _hey = _hi.send _m
        y << _hey
        NIL_
      end

      # --

      def assimilate_with_same_type_ exp
        Siblings_::List_through_Treeish_Aggregation::Assimilate[ self, exp ]
      end

      def number
        @suffixed_proper_constituency.number_exponent_symbol_
      end

      def person
        @suffixed_proper_constituency.person_exponent_symbol_
      end

      def lemma  # only for use by #spot-3 (machine reading)
        @lemma_symbol
      end

      def lemma_symbol
        @lemma_symbol
      end

      def category_symbol_
        :_noun_phraseish_
      end

      def _can_aggregate_
        true
      end
    end

    class Redux_Abstract_Base  # this lib only

      def initialize asc
        if asc
          @association_symbol_ = asc.name_symbol
        end
      end

      def association_symbol_
        @association_symbol_
      end

      def _aggregate_ exp
        if self.category_symbol_ == exp.category_symbol_
          yes = assimilate_with_same_type_ exp
          if yes
            self
          else
            yes
          end
        end
      end

      def _is_mutable_list_
        false
      end
    end

    Natural_defaults___ = Lazy_.call do

      class Natural_Defaults____

        class << self
          private :new
        end

        def number_exponent_symbol_
          :singular
        end

        def person_exponent_symbol_
          :third
        end

        def has_content_
          false
        end

        new
      end
    end

    Natural_defaults = Lazy_.call do

      class These_Natural_Defaults___

        class << self
          private :new
        end

        def number
          :singular
        end

        def person
          :third
        end

        new
      end
    end

    # ==

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
        Home_::Sexp::Quad_Count.fetch @_quad_count_category
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
        _st = @_list_arg.to_stream
        _es = Siblings_::List.via_ _st
        @noun_phrase.prepend_adjective_phrase _es
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
