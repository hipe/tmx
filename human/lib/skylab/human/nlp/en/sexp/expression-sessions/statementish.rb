module Skylab::Human

  module NLP::EN::Sexp

    class Expression_Sessions::Statementish

      class << self

        alias_method :begin_, :new
      end  # >>

      def initialize
        @_prefixed_prepositional_phrase_that_needs_commma = nil
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
        @_prefixed_prepositional_phrase_that_needs_commma = sym
      end

      attr_accessor(
        :subject,
        :verb_phrase,
      )

      def express_into_under y, expag

        o = Home_::Phrase_Assembly.begin_phrase_builder

        s_ish = @_prefixed_prepositional_phrase_that_needs_commma
        if s_ish
          o.add_string s_ish.id2name  # ..
          o.add_comma
        end

        _ = @subject.express_into_under "", expag
        o.add_string _

        _ = @verb_phrase.express_into_under_for_subject__ "", expag, @subject
        o.add_string _

        o.add_period  # ..

        o.add_newline  # #experimental

        _ = o.string_via_finish

        y << _
      end
    end
  end
end
