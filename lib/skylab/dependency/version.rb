require File.expand_path('../..', __FILE__)
require 'skylab/code-molester/sexp'
require 'skylab/pub-sub/emitter'

module Skylab
  module Dependency
    class Version < CodeMolester::Sexp
      REGEX      = /(\d+)\.(\d+)(?:\.(\d+))?/
      REGEX_FULL = /\A#{REGEX.source}\z/
      SPLITTER   = /\A(.*[^\.\d])?(#{REGEX.source})\z/

      S = ->(*a) { CodeMolester::Sexp.new(a) }

      class << self
        def parse_string_with_version string
          emitter = block_given? ? Parse.new : Parse::Singleton.loud
          block_given? and yield(emitter)
          require 'strscan'
          sexp = S[:version_string]
          s = StringScanner.new(string)
          capture = s.scan_until(REGEX) or return emitter.error(
            "version pattern not matched anywhere in string: #{string.inspect}")
          s.rest =~ REGEX and return emitter.error(
            "multiple version strings matched in string: #{string.inspect}")
          md = SPLITTER.match(capture)
          md[1] and sexp.push(S[:string, md[1]])
          sexp.push new(md[2])
          s.eos? or sexp.push(S[:string, s.rest])
          sexp
        end
      end
      def initialize str
        replace str
      end
      def replace str
        clear
        md = REGEX.match(str) or fail("invalid version string: #{str.inspect}")
        push :version
        concat [ S[:major, md[1].to_i], S[:separator, '.'], S[:minor, md[2].to_i] ]
        md[3] and concat( [ S[:separator, '.'], S[:patch, md[3].to_i] ] )
      end
      def bump! which
        node = detect(which) or fail("no such node: #{which.inspect}")
        node[1] += 1
      end
      def has_minor_version? ; !! detect(:minor) end
      def has_patch_version? ; !! detect(:patch) end
    end
  end
end


class Skylab::Dependency::Version < Skylab::CodeMolester::Sexp
  class Parse
    extend Skylab::PubSub::Emitter
    emits :informational, :error => :informational
    def error msg
      emit :error, msg
      false
    end
    def initialize
      yield self if block_given?
    end
  end
end

class Skylab::Dependency::Version::Parse
  module Singleton
    def self.loud
      @loud ||= Skylab::Dependency::Version::Parse.new do |o|
        o.on_informational { |e| $stderr.puts "#{Skylab::Dependency::Version}:#{e.tag}: #{e.message}" }
      end
    end
  end
end

