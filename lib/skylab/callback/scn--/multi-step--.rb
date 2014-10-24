module Skylab::Callback

  module Scn__

    class Multi_Step__

      Callback_::Actor.call self, :properties,
        :init,
        :gets

      def initialize
        super
        @p = -> do
          @init.call
          @p = @gets
          @init = @gets = nil
          @p.call
        end ; nil
      end

      def to_a
        to_enum.to_a
      end

      def each
        if block_given?
          while  x = gets
            yield x
          end ; nil
        else
          to_enum
        end
      end

      def gets
        @p.call
      end
    end
  end
end
