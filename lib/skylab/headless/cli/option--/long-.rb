module Skylab::Headless

  module CLI::Option

    Long_ = Headless_::Lib_::Formal_box[].const_get( :Struct, false ).

        new :__, :no, :stem, :arg do

      Headless_::Lib_::Pool[].enhance( self ).with_lease_and_release -> do
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
