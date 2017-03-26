module Skylab::Zerk

  module API

    module InterfaceExpressionAgent  # (covered by [pe]??)

      class THE_LEGACY_CLASS

        class << self
          alias_method :via_expression_agent_injection, :new
          undef_method :new
        end  # >>

    private

      # specifically we created this expression agent to render expressions
      # in "black & white" when we are rendering their messages
      # to be used in exception messages.

      def initialize injection
        @app_name_p = -> do
          injection.app_name_string
        end
      end

      alias_method :calculate, :instance_exec

      public def simple_inflection & p
        o = dup
        o.extend Home_.lib_.human::NLP::EN::SimpleInflectionSession::Methods
        o.calculate( & p )
      end

      # --

      def and_ x
        _NLP_agent.and_ x
      end

      def app_name_string
        @app_name_p[]
      end

      def both x
        _NLP_agent.both x
      end

      def code s
        ick s
      end

      def hdr string
        "#{ string }:"
      end

      def highlight string
        "** #{ string } **"
      end

      def ick x
        Home_.lib_.basic::String.via_mixed x
      end
      alias_method :ick_mixed, :ick

      def indefinite_noun lemma_s
        _NLP_agent.indefinite_noun lemma_s
      end

      def lbl x
        x
      end

      def nm name
        "'#{ name.as_slug }'"
      end

      def np_ d, s
        _NLP_agent.noun_phrase :subject, d, :subject, s
      end

      def or_ x
        _NLP_agent.or_ x
      end

      def par x
        if x
          parameter_in_black_and_white x
        else
          x
        end
      end

      def parameter_in_black_and_white x
        if x.respond_to? :ascii_only?
          "'#{ x }'"
        elsif x.respond_to? :name
          nm x.name
        else
          nm Common_::Name.via_lowercase_with_underscores_symbol x.name_symbol
        end
      end

      def plural_noun( * a )
        _NLP_agent.plural_noun( * a )
      end

      def preterite_verb lemma_i
        _NLP_agent.preterite_verb lemma_i.id2name
      end

      def progressive_verb lemma_i
        _NLP_agent.progressive_verb lemma_i.id2name
      end

      def pth x
        if x.respond_to? :to_path
          x = x.to_path
        end
        "«#{ x }»"  # :+#guillemets
      end

      def s * x_a
        _NLP_agent.s( * x_a )
      end

      def sp_ * x_a

        _NLP_agent.sentence_phrase_via_mutable_iambic x_a
      end

      def val s
        s.inspect
      end

      # -- while we don't know what we're doing

      def ick_oper sym
        _ick_via_sym sym
      end

      def ick_prim x
        _ick_via_sym x.name_symbol  # ..
      end

      def oper sym
        _ick_via_sym sym
      end

      def _ick_via_sym sym
        "'#{ sym }'"
      end

      # -- #experiment

    public

      def new_expression_context
        ::String.new
      end

      def modality_const
        NIL_
      end

      def intern  # what expression adapter?
        :Event
      end

    private

      # --

      def _NLP_agent
        @___NLP_agent ||= Home_::Expresser::NLP_EN_ExpressionAgent.new
      end

      end  # legacy class
    end  # module
  end
end
