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

    def kbd s
      em s
    end

    def omg s
      ick s
    end

    def plugin_host_metaservices  # see impl.
      @_phm ||= Pen::Experimental_::Plugin_Host_MetaServices_.new self
    end

    alias_method :calculate, :instance_exec

    Headless::SubClient::EN_FUN[ self, :private, %i( s ) ]

  end

  Pen::MINIMAL = ::Object.new.extend Pen::InstanceMethods

end
