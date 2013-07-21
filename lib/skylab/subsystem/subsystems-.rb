module Skylab

  module Subsystem

    module Subsystems_

      # this is the experimental internal way we load a subsystem.
      # all it really is is like extending ::Skylab with MAARS, which we
      # must *not* do (you will really end up with a ball of mud then.)
      # this is not for general use. sub-products and sub-systems must
      # use the `require_subsystem` facility.

      def self.const_missing c
        const_set c, Subsystems__::Require_[ c ]
      end

      def self.require_subsystem c
        Subsystems__::Require_[ c ]
      end
    end

    module Subsystems__

      Require_ = -> c do
        if ! ::Skylab.const_defined? c, false
          require ::Skylab.dir_pathname.join( "#{ Quick_[ c ] }/core" ).to_s
        end
        ::Skylab.const_get c, false
      end

      Quick_ = -> c do
        c.to_s.gsub( /(?<=[a-z])([A-Z])/ ) { "-#{ $1 }" }.downcase
      end
    end
  end
end
