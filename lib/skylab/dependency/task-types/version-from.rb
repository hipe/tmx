require File.expand_path('../../task', __FILE__)
require File.expand_path('../../version-range', __FILE__)
require 'stringio'
require 'skylab/face/open2'


module Skylab
  module Dependency
    class TaskTypes::VersionFrom < Task

      attribute :version_from
      attribute :parse_with, :required => false
      attribute :must_be_in_range, :required => false
      attribute :presupposes, :required => false # experimental, must be pushed up if stays

      include ::Skylab::Face::Open2

      def run *a
        @ui, @req = a
        version, used_regex = parse_version_string
        if used_regex
          ui.err.puts "  #{hi('version:')} #{version}"
        else
          ui.err.puts version.split("\n").map { |s| "  #{hi('version')}: #{s}" }
        end
        ui.err.puts "#{me}: #{@version_from}"
      end

      def check_presuppositions
        @presupposes or return true
        parent_graph.node(@presupposes).check
      end

      def check
        check_presuppositions or return false
        version_range = build_version_range
        version_string = get_version_string
        if version_range.match(version_string)
          ui.err.puts("  #{hi 'version ok'}: version #{version_string} is in range #{version_range}")
          true
        else
          ui.err.puts("  #{ohno 'version mismatch'}: needed #{version_range} had #{version_string}")
          false
        end
      end

      alias_method :slake, :check # this is a check-only task, so they are the same

      RegexpRegexp = %r{\A/(.+)/([a-z]*)\z}
      ModifierRe = /\A[imox]*\z/

      def build_regex str
        if RegexpRegexp =~ str
          regex_body, modifiers = [$1, $2]
          ModifierRe =~ modifiers or
            _fail("bad modifiers #{modifiers.inspect}, need #{ModifierRe.source}")
          Regexp.new(regex_body, modifiers)
        else
          _fail("Failed to parse regexp: #{str.inspect}.  Needed #{RegexpRegexp.source}")
        end
      end

      def get_version_string
        parse_version_string.first
      end

      def parse_version_string
        @parse_with and @regex = build_regex(@parse_with)
        buffer = StringIO.new
        read = lambda { |s| buffer.write(s) }
        open2(version_from) { |on| on.out(&read); on.err(&read) }
        str = buffer.rewind && buffer.read
        if @regex and @regex =~ str
          [$1, true]
        else
          [str, false]
        end
      end

      def build_version_range
        @must_be_in_range or _fail(<<-HERE.gsub(/\n */,' ').strip
          Do not use "version from" as a target without a "must be in range" assertion.
        HERE
        )
        VersionRange.build(@must_be_in_range)
      end
    end
  end
end
