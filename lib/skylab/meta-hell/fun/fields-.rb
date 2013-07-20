module Skylab::MetaHell

  module FUN::Fields_

    Metafields_ = ::Struct.new :client, :method, :field_i_a, :do_super,
                                 :scan_method

    op_h = ::Hash[ Metafields_.members.map do |i|
      [ i, -> o, a do
        o[ i ] = a.shift
        nil
      end ]
    end ].freeze

    fields = -> * i_a do
      o = Metafields_.new
      op_h.fetch( i_a.shift )[ o, i_a ] while i_a.length.nonzero?
      mod, method_i, field_i_a, do_super, scan_method_i = o.to_a
      mod.const_set :BASIC_FIELDS_H_,
        ::Hash[ field_i_a.map { |i| [ i, :"@#{ i }" ] } ].freeze
      method_i &&  Define_method_[ mod, method_i, do_super ]
      scan_method_i && Define_scan_method_[ mod, scan_method_i ]
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

    Define_method_ = -> mod, method_i, do_super do
      mod.send :define_method, method_i do |*a|
        i_a = [ ] ; h = self.class::BASIC_FIELDS_H_  # #ancestor-const-ok
        while a.length.nonzero?
          i_a << ( i = a.shift )
          instance_variable_set h.fetch( i ), a.fetch( 0 )
          a.shift
        end
        Nil_out_the_rest_[ self, i_a ]
        super() if do_super  # imagine prepend, imagine block given
        nil
      end
      nil
    end

    Define_scan_method_ = -> mod, scan_method_i do
      mod.send :define_method, scan_method_i do |a|  # NOTE `a` not `*a`
        i_a = [ ] ; h = self.class::BASIC_FIELDS_H_
        while a.length.nonzero?
          (( ivar = h[ i = a.fetch( 0 ) ] )) or break
          i_a << i
          a.shift ; instance_variable_set ivar, a.fetch( 0 ) ; a.shift
        end
        Nil_out_the_rest_[ self, i_a ]
        nil  # you can figure it out if you try
      end
    end

    Nil_out_the_rest_ = -> obj, i_a do
      obj.instance_exec do
        h = self.class::BASIC_FIELDS_H_
        ( h.keys - i_a ).each do |ii|
          instance_variable_set h.fetch( ii ), nil
        end
      end
    end

    Iambic_detect_ = -> i, a do
      ( 0 ... ( a.length / 2 )).reduce 0 do |_, idx|
        i == a[ idx * 2 ] and break a[ idx * 2 + 1 ]
      end
    end
  end
end
