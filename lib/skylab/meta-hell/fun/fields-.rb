module Skylab::MetaHell

  module FUN::Fields_

    # using the basic fields facility out of the box only gives you
    # a readable way to set instance variables via a constructor
    #
    #     class Foo
    #       MetaHell::FUN.fields[ self, :ding, :bat ]
    #     end
    #
    #     (( FOO = Foo.new )).instance_variables.sort  # => [ :@bat, :@ding ]
    #
    # it does not, however, give you attr readers
    #
    #     FOO.respond_to?( :bat )  # => false
    #     FOO.class.private_method_defined?( :bat )  # => false
    #
    # it sets *all* field ivars to nil, and then sets the values given
    #
    #     foo = Foo.new( :bat, :x )
    #     foo.instance_variable_get( :@bat )  # => :x
    #     foo.instance_variable_get( :@ding )  # => nil
    #
    # although it does not enforce required fields, it enforces the valid set
    #
    #     Foo.new( :ding, :x, :bat, :y, :bazzle, :z )  # => KeyError: key not found: :bazzle

    Metafields_ = ::Struct.new :client, :method, :scan_method,
      :do_super, :struct_like, :field_i_a

    arg = -> o, i, a do
      o[ i ] = a.fetch 0 ; a.shift ; nil
    end

    flag = -> o, i, _ do
      o[ i ] = true ; nil
    end

    arg_h = {
      client: arg,
      method: arg,
      scan_method: arg,
      do_super: flag,
      struct_like: flag,
      field_i_a: arg }.freeze

    fields = -> * a do
      o = Metafields_.new
      while a.length.nonzero?
        ii = a.shift
        arg_h.fetch( ii )[ o, ii, a ]
      end
      mod = o.client
      mod.const_set :BASIC_FIELDS_H_,
        ::Hash[ o.field_i_a.map { |i| [ i, :"@#{ i }" ] } ].freeze
      if o.struct_like
        o.method ||= :initialize
        Define_struct_like_methods_[ mod, o.field_i_a ]
      end
      o.method && Define_method_[ mod, o.method, o.do_super ]
      o.scan_method && Define_scan_method_[ mod, o.scan_method ]
      nil
    end
    define_singleton_method :[], &fields

    o = FUN_.o

    o[:fields] = -> mod, *field_i_a do
      fields[ :client, mod,
              :method, :initialize,
              :field_i_a, field_i_a,
              :do_super ]
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
        Nil_out_the_rest_[ h, self, i_a ]
        super() if do_super  # imagine prepend, imagine block given
        nil
      end
      nil
    end

    Define_struct_like_methods_ = -> mod, field_i_a do
      field_i_a.freeze  # we take what is not ours
      mod.class_exec do
        const_set :BASIC_FIELD_A_, field_i_a
        class << self
          alias_method :[], :new  # if you aren't using `initialize` then ??
        end
        def members ; self.class::BASIC_FIELD_A_ end
        attr_accessor( * field_i_a )
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
        Nil_out_the_rest_[ h, self, i_a ]
        nil  # you can figure it out if you try
      end
    end

    Nil_out_the_rest_ = -> ivar_h, obj, i_a do
      obj.instance_exec do
        ( ivar_h.keys - i_a ).each do |ii|
          ivar = ivar_h.fetch ii
          instance_variable_defined? ivar or instance_variable_set ivar, nil
        end
      end
    end

    Iambic_detect_ = -> i, a do
      ( 0 ... ( a.length / 2 )).reduce 0 do |_, idx|
        i == a[ idx * 2 ] and break a[ idx * 2 + 1 ]
      end
    end

    # Iambic_detect_
    # is a hack that lets to peek into iambic arrays:
    #
    #   a = [ :one, 'two', :three, 'four' ]
    #   Iambic_detect_[ :three, a ]  # => 'four'

  end
end
