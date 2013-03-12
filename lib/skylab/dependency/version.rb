module Skylab::Dependency
  class Version < CodeMolester::Sexp

    REGEX      = /(\d+)\.(\d+)(?:\.(\d+))?/ # #bound

    split_rx = /\A(?<prefix>.*[^\.\d])?(?<scalar>#{REGEX.source})\z/

    s = ->(* a) { CodeMolester::Sexp.new a }

    define_singleton_method :parse_string_with_version do |str, &err|
      res = nil
      error = -> msg do
        conduit = if err then Parse.new( err ) else Parse.loude_singleton end
        res = conduit.error msg
      end
      begin
        scn = Dependency::Services::StringScanner.new str
        capture = scn.scan_until REGEX
        capture or break error[
          "version pattern not matched anywhere in string: #{ str.inspect }" ]
        if scn.rest =~ REGEX
          break error[
            "multiple version strings matched in string: #{ str.inspect }" ]
        end
        md = split_rx.match capture # look at the regexes, should never fail
        sexp = s[ :version_string ]
        sexp.push s[ :string, md[:prefix] ] if md[:prefix]
        sexp.push new(md[:scalar])
        sexp.push s[ :string, scn.rest ] if ! scn.eos?
        res = sexp
      end while nil
      res
    end

    def bump! which
      node = detect(which) or fail("no such node: #{ which.inspect }")
      node[1] += 1
    end

    def has_minor_version? ; !! detect(:minor) end

    def has_patch_version? ; !! detect(:patch) end

  protected

    def initialize str
      replace str
    end

    define_method :replace do |str|
      clear
      md = REGEX.match(str) or fail("invalid version string: #{ str.inspect }")
      push :version
      concat [ s[:major, md[1].to_i], s[:separator, '.'], s[:minor, md[2].to_i] ]
      md[3] and concat( [ s[:separator, '.'], s[:patch, md[3].to_i] ] )
    end
  end

  Version::Parse = PubSub::Emitter.new :informational, error: :informational

  class Version::Parse

    event_class PubSub::Event::Textual

    def self.loud_singleton
      @loud ||= Dependency::Version::Parse.new( -> o do
        o.on_informational do |e|
          $stderr.puts "#{ Dependency::Version }:#{ e.stream_name }: #{ e.text }"
        end
      end )
    end
  end
end
