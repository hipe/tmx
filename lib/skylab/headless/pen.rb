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
                                  # (trying to use these when appropriate:
                        # http://www.w3schools.com/tags/tag_phrase_elements.asp)

    def em s                      # style for emphasis
      s
    end

    def hdr s                     # style as a header
      em s
    end

    def h2 s                      # style as a smaller header
      hdr s
    end

    white_rx = /[[:space:]]/

    define_method :human_escape do |s|         # like shellescape but for
      white_rx =~ s ? s.inspect : s            # humans -- basically use quotes
    end                                        # iff necessary (né smart_quotes)

    def ick s                     # style an invalid valid
      s
    end

    def kbd s                     # style as e.g kbd input, code
      em s
    end

    def omg s                     # style an error (string or msg)
      ick s                       # with excessive emphasis and
    end                           # exuberance. not for use.

    def plugin_host_metaservices  # see impl.
      @_phm ||= Pen::Experimental_::Plugin_Host_MetaServices_.new self
    end

    alias_method :calculate, :instance_exec

    Headless::SubClient::EN_FUN[ self, :private, %i( s ) ]

  end

  Pen::MINIMAL = ::Object.new.extend Pen::InstanceMethods

end
