module Skylab::CodeMolester
  class SshConfig
    def initialize path
      @pathname = ::Pathname.new path.to_s
      @valid = @data = @invalid_reason = nil
      if pathname.exist?
        s = pathname.read
        @data = _parse s
        if @data
          @valid = true
        end
      end
    end
    attr_reader :pathname
    attr_reader :valid
    alias_method :valid?, :valid
    attr_reader :invalid_reason
    def data
      false == @valid and fail("Cannot request data for an invalid file: #{@invalid_reason.inspect}")
      @data
    end
    def exist?
      pathname.exist?
    end
    def _parse string
      hosts = []
      scn = CM_::Library_::StringScanner.new string
      scn.skip(/[[:space:]]+/)
      loop do
        ok = scn.skip %r(Host  *)
        ok or return _fail "expected: \"Host\" had: #{scn.peek(20).inspect}"
        name = scn.scan %r([-a-zA-Z0-9_]+)
        name or return _fail "expected a valid name, had: #{scn.peek(20).inspect}"
        host = { :type => :host, :name => name }
        scn.skip(/[ \t]+/)
        while line = scn.scan(/\n? +[A-Za-z]+ +[^\n]+/)
          name, value = line.strip.split(/ +/)
          host[name.gsub(/([a-z])([A-Z])/){ "#{$1}_#{$2}" }.downcase.intern] = value
        end
        hosts.push host
        scn.skip(/[[:space:]]+/)
        scn.eos? and break
      end
      hosts
    end
    def _fail msg
      @valid = false
      @invalid_reason = msg || "Parsing failed (reason unknown)."
      false
    end
  end
end
