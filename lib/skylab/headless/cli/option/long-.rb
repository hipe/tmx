module Skylab::Headless

  module CLI::Option

    Long_ = Headless::Library_::Formal_Box.const_get( :Struct, false ).

        new :__, :no, :stem, :arg do

      Headless::Library_::MetaHell::Pool.
          enhance( self ).with_lease_and_release -> do

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
