module Skylab::Basic

  class List::Scanner

    class Power
      def self.[] * x_a
        from_iambic x_a
      end
      def self.from_iambic x_a
        new x_a
      end
      class << self
        private :new
      end
      def initialize x_a
        absorb_iambic_fully x_a
        init_gets_p
      end
    private
      def absorb_iambic_fully x_a
        @x_a = x_a
        begin
          send :"#{ x_a.shift }="
        end while x_a.length.nonzero?
        @x_a = nil
      end
    private
      def init=
        @init_p = @x_a.shift
      end
      def gets=
        @normal_gets_p = @x_a.shift
      end
      def init_gets_p
        @gets_p = -> do
          @init_p.call
          @gets_p = @normal_gets_p
          @init_p = @normal_gets_p = nil
          @gets_p.call
        end ; nil
      end
    public
      def to_a
        to_enum.to_a
      end
      def each
        if block_given?
          while (( x = gets ))
            yield x
          end ; nil
        else
          to_enum
        end
      end
      def gets
        @gets_p.call
      end
    end
  end
end
