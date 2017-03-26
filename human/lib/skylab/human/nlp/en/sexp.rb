module Skylab::Human

  module NLP::EN::Sexp

    #   - everything said in #spot1.5 (eponymous uncle) qualifies here
    #   - exactly [#049] the justification of "sexp"

    class << self

      def say * sexp
        express_into "", sexp
      end

      def express_sexp_into___ y, sx  # #testpoint only
        _exp = interpret_ Scanner_[ sx ]
        _exp.express_into y
      end

      def expression_via_these_ sx, asc
        scn = Scanner_[ sx ]
        _cls = _parse_class scn
        _cls.interpret_component_fully_ scn, asc
      end

      def expression_session_for * sx
        interpret_ Scanner_[ sx ]
      end

      def interpret_ scn

        if :magnetic_idea == scn.head_as_is
          scn.advance_one
          This_index___[].interpret_ scn
        else
          _cls = _parse_class scn
          _cls.interpret_ scn
        end
      end

      def _parse_class scn

        # exactly as #spot1.5, we're taking the magic away

        k = scn.gets_one
        const = CONST_VIA_SHORT_NAMES___[ k ]
        if const
          _magnetics_module.const_get const, false
        elsif :list == k
          __parse_class_when_list scn
        else
          ::Kernel._OKAY__do_me__  # #todo
        end
      end

      def __parse_class_when_list scn

        # (this got uglier when we transitioned to magnetic filenames,
        # #tombstone-A, but it's worth it)

        _const = if scn.no_unparsed_exists or ! scn.head_as_is.respond_to? :id2name
          :List_via_Items

        else
          # scanner is not empty and head token is a symbol. #cov1.3
          # currently this means it must mean it was `:list, :via, :foo_bar_baz`
          # so we derive the const name from the term.
          # (#could-cache but only called 2x in sidesystem test suite)

          Keywords_must_be[ :via, scn ]
          _terms = scn.gets_one.id2name.split UNDERSCORE_
          _scn_ = Scanner_[ _terms ]
          _ = Home_::ExpressionPipeline_::ConstString_via_TermScanner[ _scn_ ]
          "List_via_#{ _ }".intern
        end

        _magnetics_module.const_get _const, false
      end

      def _magnetics_module
        EN_::Magnetics
      end
    end  # >>

    CONST_VIA_SHORT_NAMES___ = {
      # under #tombstone-A we used to generate const names, but no longer
      for_expag: :Expression_via_ExpressionAgent,
      gerund_phraseish: :GerundPhraseish_via_ObjectNounPhrase_and_VerbLemma,
      nounish: :NounPhraseish_via_Components,
      predicateish: :VerbPhraseish_via_Components,
      statementish: :Statementish_via_Subject_and_VerbPhrase,
      word_list: :Phraseish_via_AlreadyInflectedAtoms_in_Scanner,
    }

    module AnyExpression ; class << self  # 1x. [hu] only

      def interpret_component scn, asc
        _sx = scn.gets_one
        scn_ = Scanner_[ _sx ]
        _cls = This___._parse_class scn_
        _cls.interpret_component_fully_ scn_, asc
      end
    end ; end

    class String_as_Expression  # 1x. [hu] only

      class << self
        alias_method :[], :new
        private :new
      end  # >>

      def initialize x, asc
        @_x = x
        @_ASC = asc
      end

      def express_into_under y, _
        y << @_x
      end

      def _difference_against_counterpart_ otr
        otr._x != @_x  # #equivalence
      end

      attr_reader :_x
      protected :_x

      def category_symbol_
        :_plain_old_string_
      end
    end

    # ==

    This_index___ = Lazy_.call do
      Home_::ExpressionPipeline_::BestMatchingExpression_via_Magnetics.
        index_via_magnetics_module__ EN_::Magnetics
    end

    # ==

    Keywords_must_be = Home_::Sexp::Keywords_must_be

    # ==

    EN_ = NLP::EN
    This___ = self

    # ==
  end
end
# :#tombstone-A: magnetics not expression frames, break out: many stowaways, "expression collection"
