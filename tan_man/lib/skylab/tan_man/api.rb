module Skylab::TanMan

  module API

    # ~ stowaway API-related things here for now

    class << self

      def call * x_a, & oes_p
        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end

      def expression_agent_instance  # :+[#051]
        InterfaceExpressionAgent___.instance
      end
    end  # >>

    # ~

    class InterfaceExpressionAgent___
      # follows [#ze-040]:#the-semantic-markup-guidelines

      class << self
        def instance
          @___instance ||= new
        end
        private :new
      end  # >>

      alias_method :calculate, :instance_exec

      def and_ a
        _NLP_agent.and_ a
      end

      def app_name
        Home_.name_function.as_human
      end

      def code s
        "'#{ s }'"
      end

      def hdr s
        s
      end

      def highlight string
        "** #{ string } **"
      end

      def ick x
        val x
      end

      def indefinite_noun lemma_s
        _NLP_agent.indefinite_noun lemma_s
      end

      def kbd s
        s
      end

      def lbl x
        par x
      end

      def or_ a
        _NLP_agent.or_ a
      end

      def par x
        if ! ( x.respond_to? :ascii_only? or x.respond_to? :id2name )
          x = x.name.as_lowercase_with_underscores_symbol
        end
        "'#{ x }'"
      end

      def plural_noun * a
        _NLP_agent.plural_noun( * a )
      end

      def pth s
        if DOT_ == ::File.dirname(s)
          s
        else
          ::File.basename s
        end
      end

      def s count_x, lexeme_i=:s
        count_x.respond_to?( :abs ) or count_x = count_x.length
        if :s == lexeme_i
          's' if 1 != count_x
        else
          lexeme_i
        end
      end

      def sp_ * x_a

        _NLP_agent.sentence_phrase_via_mutable_iambic x_a
      end

      def val x
        x.inspect
      end

      def _NLP_agent
        NLP_agent_instance___[]
      end

      NLP_agent_instance___ = Lazy_.call do
        self::NLP_Agent___.new
      end

      Autoloader_[ self ]
      lazily :NLP_Agent___ do

        cls = ::Class.new

        Home_.lib_.human::NLP::EN::SimpleInflectionSession.edit_module cls,
          :public,
          [ :and_, :indefinite_noun,
            :or_, :plural_noun,
            :s, :sentence_phrase_via_mutable_iambic ]

        cls
      end
    end

    DOT_ = '.'
  end
end
