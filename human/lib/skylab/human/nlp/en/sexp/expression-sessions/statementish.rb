module Skylab::Human

  module NLP::EN::Sexp

    class Expression_Sessions::Statementish

      COMPONENTS = Attributes_[

        freeform_prefix: [ :_read,
          :custom_interpreter_method_of, :xyzzy_red ],

        subject: [ :component, :_read, :_write ],

        verb_phrase: [ :component, :_read, :_write ],
      ]

      attr_writer( * COMPONENTS.symbols( :_write ) )

      attr_reader( * COMPONENTS.symbols( :_read ) )

      class << self

        def expression_via_sexp_stream_ st
          begin_.__init_via_sexp_stream st
        end

        alias_method :begin_, :new
        undef_method :new
      end  # >>

      def initialize
        @freeform_prefix = nil
        @subject = nil
          # (everything about this is hacked for now..)
      end

      def __init_via_sexp_stream st

        COMPONENTS.init_via_stream self, st
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

      def __verb_phrase__component_association
        Siblings_::Predicateish
      end

      def xyzzy_red st
        x = st.gets_one
        if x
          @freeform_prefix = Siblings_::Freeform_Phrase.via_ x
        else
          @freeform_prefix = x
        end
        KEEP_PARSING_
      end

      def prefixed_prepositional_phrase_lemma= sym
        @freeform_prefix = Siblings_::Symbol_as_Freeform_Phrase.new sym
        sym
      end

      # --

      def express_into_under y, expag
        if @subject
          __express_into_under_as_normal y, expag
        else
          ___express_into_under_for_no_subject y, expag
        end
      end

      def ___express_into_under_for_no_subject y, expag

        # this is where we put the "ish" in statement-ISH:

        vp = @verb_phrase

        if :be == vp.lemma_symbol

          ___express_invariant_be_form y, expag
        else
          # (hi.)
          if @verb_phrase.object_noun_phrase
            This_::Passive_voice___[ y, expag, self ]
          else
            __express_into_under_as_is_for_no_subject y, expag
          end
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

        _ = @verb_phrase.express_into_under_for_subject_ "", expag, @subject
        pb.add_string _

        pb.add_period  # ..

        _common_finish y, pb
      end

      def __express_into_under_as_is_for_no_subject y, expag

        pb = _phrase_builder_common_beginning

        _ = @verb_phrase.express_into_under_for_subject_ "", expag, @subject
        pb.add_string _

        _common_finish y, pb
      end

      def _phrase_builder_common_beginning

        pb = Home_::Phrase_Assembly.begin_phrase_builder

        phrase = @freeform_prefix
        if phrase
          phrase.express_into_phrase_builder__ pb
          pb.add_comma
        end

        pb
      end

      def _common_finish y, pb

        pb.add_newline  # #experimental

        _ = pb.string_via_finish

        y << _
      end

      def association_symbol_
        :_a_statementish_typically_has_no_association_symbol_  # for etc
      end

      class List

        class << self
          alias_method :via_array_, :new
          undef_method :new
        end  # >>

        def initialize a
          @_a = a
        end

        def express_into_under y, expag
          @_a.each do |x|
            x.express_into_under y, expag
          end
          y
        end
      end

      This_ = self
    end
  end
end
# #pending-rename
