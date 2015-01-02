module Skylab::Brazen

  module API

    class Expression_Agent__

      # specifically we created this expression agent to render expressions
      # in "black & white" when we are rendering their messages
      # to be used in exception messages.

      def initialize k
        @app_name_p = -> do
          k.app_name
        end
      end

      alias_method :calculate, :instance_exec

      def and_ x
        _NLP_agent.and_ x
      end

      def app_name
        @app_name_p[]
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
        "'#{ x }'"
      end

      def indefinite_noun * a
        _NLP_agent.indefinite_noun.via_arglist a
      end

      def nm name
        "'#{ name.as_slug }'"
      end

      def or_ x
        _NLP_agent.or_ x
      end

      def par x
        if x.respond_to? :ascii_only?
          "'#{ x }'"
        else
          nm x.name
        end
      end

      def plural_noun * a
        _NLP_agent.plural_noun.via_arglist a
      end

      def preterite_verb lemma_i
        _NLP_agent.preterite_verb[ lemma_i.id2name ]
      end

      def progressive_verb lemma_i
        _NLP_agent.progressive_verb[ lemma_i.id2name ]
      end

      def pth x
        "«#{ x }»"  # :+#guillemets
      end

      def s * x_a
        _NLP_agent.s( * x_a )
      end

      def val s
        s.inspect
      end

      def _NLP_agent
        @context ||= self.class.NLP_agent.new
      end

      class << self

        def NLP_agent
          const_get( :NLP_agent__, false ).call
        end
      end

      NLP_agent__ = Callback_.memoize do
        NLP_Agent__ = LIB.make_NLP_agent :public,
          [ :and_, :indefinite_noun, :or_, :plural_noun,
            :preterite_verb, :progressive_verb, :s ]
      end

      module LIB

        class << self

          def make_NLP_agent * x_a
            cls = ::Class.new
            x_a.unshift cls
            LIB_.NLP_EN_methods.via_arglist x_a
            cls
          end
        end
      end
    end
  end
end
