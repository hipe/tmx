module Skylab::Basic

  module Enumerator

    LineStream_by = -> & p do
      LineStream_via_Enumerator[ ::Enumerator.new( & p ) ]
    end

    class LineStream_via_Enumerator < Common_::MonadicMagneticAndModel

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
