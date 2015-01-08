module Skylab::Headless

  module CLI::Option__

    Long_ = ::Struct.new :__, :no, :stem, :arg do

      Headless_.lib_.pool.enhance( self ).with_lease_and_release -> do
        # this is how we construct (*not* re-init) a flyweight.
        new '--'  # this never changes
      end

      class << self

        def lease_from_matchdata md
          if md
            o = lease
            o[ :no ], o[ :stem ], o[ :arg ] = md.captures  # #neat
            o
          else
            false
          end
        end
      end

      def clear_for_pool
        self.no = self.stem = self.arg = nil
      end

      # ~ begin thing

      def at * i_a
        i_a.map( & method( :[] ) )
      end

      # ~ end thing
    end
  end
end
