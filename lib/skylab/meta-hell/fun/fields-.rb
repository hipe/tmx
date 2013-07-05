module Skylab::MetaHell

  module FUN::Fields_

    o = FUN_.o

    o[:fields] = -> mod, *field_i_a do

      mod.const_set :H_, ::Hash[ field_i_a.map { |i| [ i, :"@#{ i }" ] } ]

      mod.send :define_method, :initialize do |*a|
        i_a = [ ] ; h = self.class.const_get( :H_, false )
        while a.length.nonzero?
          i_a << ( i = a.shift )
          instance_variable_set h.fetch( i ), a.fetch( 0 )
          a.shift
        end
        ( h.keys - i_a ).each do |ii|
          instance_variable_set h.fetch( ii ), nil
        end
      end

      nil
    end
  end
end
