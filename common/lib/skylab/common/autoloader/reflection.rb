module Skylab::Common

  module Autoloader

    module Reflection

      Each_const_value_method = -> & p do

        constants.each do |sym|
          _x = const_get sym, false
          p[ sym, _x ]
        end
      end
    end
  end
end
# #history: was eliminated from a.l a few commits back
