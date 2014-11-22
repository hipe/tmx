module Skylab::Headless

  module CLI::Option__

    Long_ = Headless_._lib.old_box_lib.struct.

        new :__, :no, :stem, :arg do

      Headless_._lib.pool.enhance( self ).with_lease_and_release -> do
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
    end
  end
end
