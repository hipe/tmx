module Skylab::Brazen

  module Scanner_

    def self.From_Block & p
      From_Proc__.new( & p )
    end

    class From_Proc__ < ::Proc
      alias_method :gets, :call
    end

    class Wrapper
      def initialize scanner, &blk
        @block = blk ; @scanner = scanner
      end
      def gets
        if (( x = @scanner.gets ))
          @block.call x
        end
      end
    end
  end
end
