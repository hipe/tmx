module Skylab::Human

  module NLP::EN

    class Magnetics::VerbPhraseish_via_Components  # [here] only

      # reached (only) in expression sexp's using the alias `predicateish`

      # important theory at :[#056].

      COMPONENTS = Attributes_[

        object_noun_phrase: [ :component, :_read, :_write ],

        auxiliary: [ :_atomic_, :_read, ],

        early_adverbial_phrase: [ :component, :_read ],

        lemma: [ :_atomic_, :ivar, :@lemma_symbol ],

        surface_verb: [ :_atomic_, :_read, ],

        # (etc other grammatical categories #here-1)

        tense: [ :_atomic_, :_read,
                 :custom_interpreter_method_of, :__interpret_tense, ],
      ]

      attr_writer( * COMPONENTS.symbols( :_write ) )

      attr_reader( * COMPONENTS.symbols( :_read ) )

      attr_accessor :lemma_symbol

      class << self

        def interpret_component scn, asc
          EN_::Sexp.expression_via_these_ scn.gets_one, asc
        end

        def interpret_component_fully_ scn, _asc
          interpret_ scn
        end

        def interpret_ scn
          new._init_via_sexp_scanner scn
        end

        alias_method :begin_, :new
        private :new
      end  # >>

      def initialize
        @auxiliary = nil
        @early_adverbial_phrase = nil
        @lemma_symbol = nil
        @object_noun_phrase = nil
        @tense = nil
      end

      def initialize_copy _
        NOTHING_   # (hi.)
      end

      def _init_via_sexp_scanner scn

        COMPONENTS.init_via_argument_scanner self, scn
      end

      def __early_adverbial_phrase__component_association
        Magnetics::Phraseish_via_AlreadyInflectedAtom
      end

      def __object_noun_phrase__component_association
        Magnetics::NounPhraseish_via_Components
      end

      def nilify_object__
        @object_noun_phrase = nil
      end

      def << sym
        instance_variable_set REDUCED_REDUNDANCY___.fetch( sym ), sym
        self
      end

      REDUCED_REDUNDANCY___ = {
        # (we rewrite a swath of this rather than depend on the other guy)

        # (etc other grammatical categories #here-1)

        present: :@tense,
        preterite: :@tense,
      }

      # --

      # ~

      def _difference_against_counterpart_ x

        Magnetics::List_via_TreeishAggregation_of_Phrases::Phrase_diff[ self, x ]
      end

      def _aggregate_ diff_x, otr

        if ! diff_x
          self._WHERE
        end

        if 1 == diff_x.length
          k = diff_x.first
          x = send k
          x_ = otr.send k
          send :"__aggregate__#{ k }__", x, x_
        else
          NOTHING_
        end
      end

      def __aggregate__surface_verb__ x, x_
        @surface_verb = "#{ x } and #{ x_ }"  # meh
        self
      end

      # ~

      def to_statementish_stream_for_subject * sexp

        # in EN there is of course conjugation of verbs with their subjects
        # so the predicate phrases have to "know" what their subjects are
        # to express themselves..

        Common_::Stream.once do
          o = Magnetics::Statementish_via_Subject_and_VerbPhrase.begin_
          o.attach_sexp__ sexp, :subject
          o.verb_phrase = self
          o
        end
      end

      def to_statementish_stream_for_no_subject  # #spot1.3

        Common_::Stream.once do
          o = Magnetics::Statementish_via_Subject_and_VerbPhrase.begin_
          o.verb_phrase = self
          o
        end
      end

      # ~

      def express_into_under_for_subject_ y, expag, subj

        if @auxiliary
          __etc_when_auxiliary y, expag, subj
        else
          __etc_when_normal y, expag, subj
        end
      end

      def __etc_when_auxiliary y, expag, subj

        if @tense
          self._WAHOO  # e.g "must have made"
        end
        y << @auxiliary.id2name
        y << SPACE_
        _express_any_early_adverbial_phrase y
        __express_verb_stem y
        _express_any_object y, expag
      end

      def __etc_when_normal y, expag, subj

        # near `inflect_words_into_against_sentence_phrase`
        # [#].2 explains why we do this anew at each expression

        _express_verb_agreeing_with y, subj
        _express_any_object y, expag
      end

      def express_into_under y, expag  # NOTE -

        if @auxiliary
          self._EEK
        end

        # only for above, for passive voice. normally a verb-phrase cannnot
        # express without knowing its subject. if these semantics for this
        # method are ever a problem, make an adapter class "past participle"

        _express_verb_agreeing_with_natural_default_subject y
        @object_noun_phrase and self._SANITY
        y
      end
      protected :express_into_under

      def __express_verb_stem y
        sym = @lemma_symbol
        if sym
          y << sym.id2name
        else
          @surface_verb or self._SANITY
          y << @surface_verb
        end
      end

      def _express_verb_agreeing_with_natural_default_subject y

        _ = Magnetics::NounPhraseish_via_Components::Natural_defaults[]
        _express_verb_agreeing_with y, _
      end

      def _express_verb_agreeing_with y, subj

        _express_any_early_adverbial_phrase y

        ph = Skylab::Human::NLP::EN::POS::Verb[ subj, @lemma_symbol.id2name ]

        ph << ( @tense || :present )
        # (etc other grammatical categories #here-1)
        ph.express_into y
      end

      def _express_any_early_adverbial_phrase y
        x = @early_adverbial_phrase
        if x
          x.express_into_under y, :_EEK_
          y << SPACE_
        end
        NIL_
      end

      def _express_any_object y, expag

        o = @object_noun_phrase
        if o
          y << SPACE_
          o.express_into_under y, expag
        else
          y
        end
      end

      def lemma  # only for use by #spot1.3 (machine reading)
        @lemma_symbol
      end

      def association_symbol_  # ..
        :_predicateish_
      end

      def category_symbol_
        :predicateish
      end

      def _can_aggregate_
        true
      end

      class List

        # map the same subject on to several sequential predicates.
        # currently, adds "also" in "foo is bar. also foo has baz."
        # in the future we might add production of use of pronouns
        # with #antecedent-distance.

        class << self
          alias_method :via_array_, :new
          undef_method :new
        end  # >>

        def initialize a
          @_a = a
        end

        def to_statementish_stream_for_subject * sx

          # this is wild - this is wild.

          asc = Association_via_symbol_[ :subject ]
          expr = EN_::Sexp.expression_via_these_ sx, asc

          make_statement = -> vp do
            o = Magnetics::Statementish_via_Subject_and_VerbPhrase.begin_
            o.attach_ expr, asc
            o.verb_phrase = vp
            o
          end

          stmr = Home_::Magnetics::List_via_Eventing::Simple.begin

          stmr.on_first = -> verb_phrase do
            make_statement[ verb_phrase ]  # (hi.)
          end

          stmr.on_subsequent = -> verb_phrase do
            o = make_statement[ verb_phrase ]
            o.prefixed_prepositional_phrase_lemma = :also
            o
          end

          stmr.to_stream_around Stream_[ @_a ]
        end

        def read_only_array___
          @_a
        end
      end
    end
  end
end
