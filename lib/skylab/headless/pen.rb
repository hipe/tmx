module Skylab::Headless

  module Pen  # [#084] what is the deal with expression agents..
    module Bundles
      Expressive_agent = -> _ do  # :+[#121] bundle as def macro
      private
        def say &p
          expression_agent.calculate( & p )
        end
      end
    end
  end

  module Pen::InstanceMethods

    # follows [#fa-052]:#the-semantic-markup-guidelines

    alias_method :calculate, :instance_exec

    def em s
      s
    end

    def hdr s
      em s
    end

    def h2 s
      hdr s
    end

    white_rx = /[[:space:]]/

    define_method :human_escape do |s|
      white_rx =~ s ? s.inspect : s
    end

    def ick s
      s
    end

    def indefinite_noun * a
      _NLP_agent.indefinite_noun.call_via_arglist a
    end

    def kbd s
      em s
    end

    def omg s
      ick s
    end

    def plugin_host_metaservices  # see impl.
      @_phm ||= Pen::Experimental_::Plugin_Host_MetaServices_.new self
    end

    def s x, i=:s
      _NLP_agent.s x, i
    end

    def _NLP_agent
      @NLP_agnt ||= NLP_agent_class__[].new
    end

    NLP_agent_class__ = Callback_.memoize do

      class NLP_Agent__

        Headless_.expression_agent.NLP_EN_methods self, :public,
          [ :and_, :indefinite_noun, :or_, :plural_noun, :s ]

        self
      end
    end
  end

  Pen::MINIMAL = ::Object.new.extend Pen::InstanceMethods

end
