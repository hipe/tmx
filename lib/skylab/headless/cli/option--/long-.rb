module Skylab::Headless

  module CLI::Option__

    Long_ = ::Struct.new :__, :no, :stem, :arg do

      _DOUBLE_DASH = '--'.freeze

      Callback_::Memoization::Pool[ self ].lease_by do

        # this is how we construct (*not* re-init) a flyweight.

        new _DOUBLE_DASH  # this never changes

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
      end  # >>

      def clear_for_pool
        self.no = self.stem = self.arg = nil
      end

      include Callback_::Box::Proxies::Struct::For::InstanceMethods
    end
  end
end
