
module Skylab::GitViz::Tasks

  class Build_RBX

    class Installed_version__

      def initialize y
        @y = y
      end

      def execute
        _, @o, @e, @w = Build_RBX::Open3[].popen3 'rbenv', 'versions'
        @ruby_a = [] ; count = 0
        while (( s = @o.gets ))
          s.chop!
          count += 1
          md = RX__.match s
          if ! md
            SYSTEM_RX__ =~ s and next  # special case
            fail "failed to parse like from rbenv - #{ s.inspect }"
          end
          ruby = Ruby__.new( * md.captures )
          PREFIX__ == ruby.prefix or next
          @ruby_a << ruby
        end
        @count = count
        resolve
      end
      PREFIX__ = 'rbx-'.freeze
      SYSTEM_RX__ = /\A[* ][ ]system\b/
      RX__ = /\A[* ][ ]([^0-9]+)?((?:\d+)(?:\.\d+)+)([^ ]+)?.*\z/
    private
      def resolve
        if @ruby_a.length.zero?
          resolve_when_zero
        else
          resolve_when_nonzero
        end
      end
      def resolve_when_zero
        if @count.zero?
          @y << "strange! no rubies known by rbenv?"
          CEASE_
        else
          @y << "of #{ @count } rubie(s) installed, none were '#{ PREFIX__ }'"
          Result__.new false
        end
      end
      def resolve_when_nonzero
        @ruby_a.sort_by! do |ruby|
          ruby.version
        end
        Result__.new true, @ruby_a.last
      end

      Result__ = ::Struct.new :version_is_installed, :ruby

      class Ruby__
        def initialize prefix, version_s, suffix
          @version = ::Gem::Version.new version_s
          @prefix = prefix ; @suffix = suffix
        end
        attr_reader :prefix, :version
        def to_s
          "#{ @prefix }#{ @version }#{ @suffix }"
        end
      end
    end
  end
end
