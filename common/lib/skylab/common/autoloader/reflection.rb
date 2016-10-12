module Skylab::Common

  module Autoloader

    module Reflection

      Each_const_value_method = -> & p do

        constants.each do |sym|
          p[ const_get sym, false ]
        end
      end
    end
  end
end
# #history: was eliminated from a.l a few commits back
