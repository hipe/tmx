$:.include?(_skylab = File.expand_path('../../..', __FILE__)) or $:.unshift(_skylab)

require 'skylab/code-molester/sexp'

module Skylab
  module Dependency
    class Version < CodeMolester::Sexp
      REGEX      = /(\d+)\.(\d+)(?:\.(\d+))?/
      REGEX_FULL = /\A#{REGEX.source}\z/
      SPLITTER   = /\A(.*[^\.\d])?(#{REGEX.source})\z/

      class << self
        def parse_string_with_version string, opts={}
          @ui = opts[:ui] || Struct.new(:out, :err).new($stdout, $stderr)
          require 'strscan'
          sexp = CodeMolester::Sexp.new
          sexp.push(:version_string)
          s = StringScanner.new(string)
          capture = s.scan_until(REGEX) or return _err(
            "version pattern not matched anywhere in string: #{string.inspect}")
          s.rest =~ REGEX and return _err(
            "multiple version strings matched in string: #{string.inspect}")
          md = SPLITTER.match(capture)
          md[1] and sexp.push([:string, md[1]])
          sexp.push new(md[2])
          s.eos? or sexp.push([:string, s.rest])
          sexp
        end
        def _err str
          @ui.err.puts("#{self} ERROR: #{str}")
          false
        end
      end
      def initialize str
        md = REGEX.match(str) or raise ArgumentError.new("invalid version string: #{str.inspect}")
        push :version
        concat [[:major, md[1].to_i], [:separator, '.'], [:minor, md[2].to_i]]
        md[3] and concat([[:separator, '.'], [:patch, md[3].to_i]])
      end
      def bump! which
        node = detect(which)
        unless node
          raise ArgumentError.new("no such node: #{which.inspect}") # this is not guaranteed to stay this kind of exception
        end
        node[1] += 1
      end
    end
  end
end


