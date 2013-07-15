module Skylab::MetaHell

  module FUN::Fields_

    Metafields_ = ::Struct.new :client, :method, :field_i_a, :do_super

    op_h = ::Hash[ Metafields_.members.map do |i|
      [ i, -> o, a do
        o[ i ] = a.shift
        nil
      end ]
    end ].freeze

    fields = -> * i_a do
      o = Metafields_.new
      op_h.fetch( i_a.shift )[ o, i_a ] while i_a.length.nonzero?
      mod, method_i, field_i_a, do_super = o.to_a
      mod.const_set :BASIC_FIELDS_H_,
        ::Hash[ field_i_a.map { |i| [ i, :"@#{ i }" ] } ].freeze
      mod.send :define_method, method_i do |*a|
        i_a = [ ] ; h = self.class::BASIC_FIELDS_H_  # #ancestor-const-ok
        while a.length.nonzero?
          i_a << ( i = a.shift )
          instance_variable_set h.fetch( i ), a.fetch( 0 )
          a.shift
        end
        ( h.keys - i_a ).each do |ii|
          instance_variable_set h.fetch( ii ), nil
        end
        super() if do_super  # imagine prepend, imagine block given
        nil
      end
      nil
    end

    define_singleton_method :[], &fields

    o = FUN_.o

    o[:fields] = -> mod, *field_i_a do
      fields[ :client, mod,
              :method, :initialize,
              :field_i_a, field_i_a,
              :do_super, true ]
      nil
    end
  end
end
