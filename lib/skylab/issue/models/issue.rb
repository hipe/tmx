module Skylab::Issue
  class Models::Issue
    include Issue::Core::SubClient::InstanceMethods # #todo why?


    def self.build_flyweight request_client, pathname
      new request_client, pathname
    end


    # --*--

    def date
      @tree[:rest][1,10]
    end

    def identifier
      @tree[:identifier]
    end

    def integer                   # used by svc to assign new number
      @tree[:identifier].to_i     # let's break this soon - ok ?
    end

    def invalid_info
      res = nil
      begin
        break if valid?
        meth = "invalid_info_#{ @normalized_invalid_reason }"
        res = send meth
      end while nil
      res
    end

    attr_reader :line             # (only for error reporting)

    def line! line, index         # for #flyweighting, the center of it
      clear!
      @index = index
      @line = line
      self
    end

    def line_number
      @index + 1
    end

    def message
      @tree[:rest][12..-1]
    end

    attr_reader :pathname


    rx = %r{\A  \[  \#  (?<identifier> \d+ )  \]   (?<rest>.*)   \z}x

    define_method :valid? do
      res = nil
      begin
        if @tree                  # valid, don't parse again
          res = true
          break
        end
        if false == @tree         # invalid, don't parse again
          res = false
          break
        end
        if ! @line                # undefined, nothing to parse
          break
        end
        md = rx.match @line
        if ! md
          @normalized_invalid_reason = :line_failed_to_match_regex
          break( res = @tree = false )
        end
        @tree = md
        res = true
      end while nil
      res
    end

  protected

    def initialize request_client, pathname
      clear!
      _sub_client_init! request_client
      @pathname = pathname
    end

    def clear!
      _sub_client_clear!
      @index = nil
      @line = nil
      @normalized_invalid_reason = nil
      @tree = nil
      self
    end

    def invalid_info_line_failed_to_match_regex
      hack = @normalized_invalid_reason.to_s.gsub '_', ' '
      {
        invalid_reason:              hack,
        line:                        @line,
        line_number:                 line_number,
        normalized_invalid_reason:   @normalized_invalid_reason,
        pathname:                    pathname
      }
    end
  end
end
