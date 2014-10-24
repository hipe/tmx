module Skylab::Basic

  module Enumerator

    class << self

      def line_scanner * a, & p
        if p
          Line_Scanner__.new ::Enumerator.new( * a, & p )
        elsif a.length.zero?
          Line_Scanner__
        else
          Line_Scanner__.new( * a )
        end
      end
    end

    class Line_Scanner__

      def initialize enum
        @p = enum.method :next
      end

      def gets
        @p.call
      rescue ::StopIteration
        @p = EMPTY_P_
        nil
      end
    end
  end
end
