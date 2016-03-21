module Skylab::Human

  module NLP::EN::Sexp

    class Expression_Sessions::Predicateish

      class << self

        def expression_via_sexp_stream_ st
          new.__init_via_sexp_stream st
        end

        private :new
      end  # >>

      COMPONENTS = Attributes_[
        object_noun_phrase: :component,
        verb_lemma: :_atomic_,
      ]

      attr_reader( * COMPONENTS.symbols )

      def __init_via_sexp_stream st

        o = COMPONENTS.begin_parse_and_normalize_for self
        o.argument_stream = st
        _ok = o.execute
        _ok && self
      end

      def __object_noun_phrase__component_association
        Siblings_::Nounish
      end

      # --

      def express_into_under_for_subject__ y, expag, subj

        # `inflect_words_into_against_sentence_phrase`

        vp = EN_::POS::Verb[ subj, @verb_lemma.id2name ]

        # vp << :present  # ..

        y << vp.to_string

        y << SPACE_

        @object_noun_phrase.express_into_under y, expag
      end

      def to_statementish_stream_for_subject * sexp

        # in EN there is of course conjugation of verbs with their subjects
        # so the predicate phrases have to "know" what their subjects are
        # to express themselves..

        Callback_::Stream.once do
          o = Siblings_::Statementish.begin_
          o.attach_sexp__ sexp, :subject
          o.verb_phrase = self
          o
        end
      end

      def association_symbol_  # ..
        :_predicateish_
      end

      def category_symbol_
        :predicateish
      end

      class List

        class << self
          alias_method :via_, :new
          private :new
        end  # >>

        def initialize a
          @_a = a
        end

        def to_statementish_stream_for_subject * sx

          # this is wild - this is wild.

          asc = Here_.association_via_symbol_ :subject
          expr = Here_.expression_via_these_ sx, asc

          make_statement = -> vp do
            o = Siblings_::Statementish.begin_
            o.attach_ expr, asc
            o.verb_phrase = vp
            o
          end

          _ = Home_::Sexp::Expression_Sessions::List_through_Eventing::Simple
          stmr = _.new

          stmr.on_first = -> verb_phrase do
            make_statement[ verb_phrase ]  # (hi.)
          end

          stmr.on_subsequent = -> verb_phrase do
            o = make_statement[ verb_phrase ]
            o.prefixed_prepositional_phrase_lemma = :also
            o
          end

          stmr.to_stream_around Callback_::Stream.via_nonsparse_array @_a
        end

        def read_only_array___
          @_a
        end
      end
    end
  end
end
