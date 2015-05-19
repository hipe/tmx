module Skylab::TanMan

  module API

    # ~ stowaway API-related things here for now

    class << self

      def call * x_a, & oes_p
        bc = TanMan_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end

      def expression_agent_class
        Expression_Agent__
      end

      def expression_agent_instance  # :+[#051]
        @expag ||= Expression_Agent__.new TanMan_.application_kernel_
      end
    end  # >>

    # ~

    class Expression_Agent__  # follows [#fa-052]:#the-semantic-markup-guidelines

      class << self
        def NLP_agent_class
          NLP_agent___[]
        end
      end  # >>

      def initialize k
        # you could use kernel for app_name but we don't
      end

      alias_method :calculate, :instance_exec

      def and_ a
        _NLP_agent.and_ a
      end

      def app_name
        TanMan_.name_function.as_human
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
        pn = ::Pathname.new "#{ s }"
        if '.' == pn.dirname.to_s
          s
        else
          pn.basename.to_path
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

      def val x
        x.inspect
      end

      def _NLP_agent
        @NLP_agent ||= self.class.NLP_agent_class.new
      end

      NLP_agent___ = Callback_.memoize do
        NLP_Agent____ = Brazen_.expression_agent_library.make_NLP_agent :public,
          [ :and_, :indefinite_noun, :or_, :plural_noun, :s ]
      end
    end
  end
end
