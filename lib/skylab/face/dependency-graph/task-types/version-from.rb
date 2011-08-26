require File.expand_path('../../task', __FILE__)
require 'stringio'

module Skylab::Face
  class DependencyGraph
    class TaskTypes::VersionFrom < Task

      attribute :version_from
      attribute :parse_with, :required => false

      include Open2

      def run
        @parse_with and @regex = build_regex(@parse_with)
        buffer = StringIO.new
        read = lambda { |s| buffer.write(s) }
        open2(version_from) { |on| on.out(&read); on.err(&read) }
        str = buffer.rewind && buffer.read
        if @regex and @regex =~ str
          @ui.err.puts "  #{hi('version:')} #{$1}"
        else
          @ui.err.puts str.split("\n").map { |s| "  #{hi('version')}: #{s}" }
        end
        @ui.err.puts "#{hi_name}: #{@version_from}"
      end

      RegexpRegexp = %r{\A/(.+)/([a-z]*)\z}
      ModifierRe = /\A[imox]*\z/

      def build_regex str
        if RegexpRegexp =~ str
          regex_body, modifiers = [$1, $2]
          ModifierRe =~ modifiers or
            fail("bad modifiers #{modifiers.inspect}, need #{ModifierRe.source}")
          Regexp.new(regex_body, modifiers)
        else
          fail("Failed to parse regexp: #{str.inspect}.  Needed #{RegexpRegexp.source}")
        end
      end
    end
  end
end
