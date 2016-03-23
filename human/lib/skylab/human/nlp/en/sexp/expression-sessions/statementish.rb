module Skylab::Human

  module NLP::EN::Sexp

    class Expression_Sessions::Statementish

      class << self

        alias_method :begin_, :new
        undef_method :new
      end  # >>

      def initialize
        @subject = nil
        @_prefixed_prepositional_phrase_that_needs_comma = nil
          # (everything about this is hacked for now..)
      end

      def attach_sexp__ sx, association_sym

        asc = Here_.association_via_symbol_ association_sym
        _expr = Here_.expression_via_these_ sx, asc
        attach_ _expr, asc
      end

      def attach_ expression, asc
        send asc.attr_writer_method_name, expression  # or use #[#fi-027] store
        NIL_
      end

      def prefixed_prepositional_phrase_lemma= sym
        @_prefixed_prepositional_phrase_that_needs_comma = sym
      end

      attr_accessor(
        :subject,
        :verb_phrase,
      )

      def express_into_under y, expag
        if @subject
          __express_into_under_as_normal y, expag
        else
          ___express_into_under_without_subject y, expag
        end
      end

      def ___express_into_under_without_subject y, expag

        # this is where we put the "ish" in statement-ISH:

        vp = @verb_phrase

        if :be == vp.lemma_symbol

          ___express_invariant_be_form y, expag
        else
          This_::Passive_voice___[ y, expag, self ]
        end
      end

      def ___express_invariant_be_form y, expag

        # much like in the "invariant be-form" of natural language, if we
        # don't know or care about the subject and the verb is "to be",
        # we can drop it entirely from the statement-ish without
        # sacraficing meaning at all:
        #
        # "??? is crazy" -> "crazy"
        # "??? is missing reqored proportors LA LA" -> "missing re[..]"
        #
        # (but note the "grammatical category" of statemenish should
        # probably be cosidered different now. more like an interjection.)

        s = ""  # #[#059] chunk from prog. string stream into this
        @verb_phrase.object_noun_phrase.express_into_under s, expag
        s << NEWLINE_
        y << s
      end

      def __express_into_under_as_normal y, expag

        pb = _phrase_builder_common_beginning

        _ = @subject.express_into_under "", expag
        pb.add_string _

        _ = @verb_phrase.express_into_under_for_subject__ "", expag, @subject
        pb.add_string _

        pb.add_period  # ..

        _common_finish y, pb
      end

      def _phrase_builder_common_beginning

        pb = Home_::Phrase_Assembly.begin_phrase_builder

        s_ish = @_prefixed_prepositional_phrase_that_needs_comma
        if s_ish
          pb.add_string s_ish.id2name  # ..
          pb.add_comma
        end

        pb
      end

      def _common_finish y, pb

        pb.add_newline  # #experimental

        _ = pb.string_via_finish

        y << _
      end

      This_ = self
    end
  end
end
