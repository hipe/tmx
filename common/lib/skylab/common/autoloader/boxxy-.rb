module Skylab::Common

  module Autoloader

    module Boxxy_  # [#030]

      module Reflection  # a stowaway sort of

        Each_const_value_method = -> & p do

          constants.each do |sym|
            p[ const_get sym, false ]
          end
        end
      end

      # ==
    end  # :#bo
  end
end
# #tombstone-3.1: full overhaul during "operator branch" era
#   (tombstones 1 & 2 are in our main spec file - they occurred before this file existed)
