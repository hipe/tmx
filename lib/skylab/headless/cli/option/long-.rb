module Skylab::Headless

  module CLI::Option

    Long_ = MetaHell::Formal::Box::kick( :Struct ).new :__, :no, :stem, :arg
    class Long_

      MetaHell::Pool.enhance( self ).with_lease_and_release -> do
        # this is how we construct (*not* re-init) a flyweight.
        new '--'  # this never changes
      end

      def self.lease_from_matchdata md
        if md
          ls = lease
          ls[:no], ls[:stem], ls[:arg] = md.captures  # wow
          ls
        else
          false
        end
      end
    end
  end
end
