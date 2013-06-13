module Skylab::MetaHell

  class DSL_DSL::Constant_Trouble  # this was test-first driven, covered.

    class << self
      alias_method :orig_new, :new
    end

    Field_ = ::Struct.new :normal, :const, :ivar

    def self.new const, superclass, field_a

      ::Class.new( self ).class_exec do

        class << self
          alias_method :new, :orig_new
        end

        h = { }
        fld_a = field_a.each_with_index.map do |i, idx|
          h[ i ] = idx
          Field_.new i, const_( i ), :"@#{ i }"
        end.freeze
        h.freeze

        dynamic [ :const, const ], [ :superclass, superclass ],
          [ :field_a, fld_a ], [ :conduit, ::Class.new.class_exec do

          define_method :initialize do |res_a|
            @set = -> i, *tpl do
              idx = h.fetch i
              res_a[ idx ].nil? or raise "can't set `#{ i }` multiple #{
                }times."
              res_a[ idx ] = tpl
              nil  # ..
            end
          end

          field_a.each do |i|
            define_method i do |*a, &b|
              1 < a.length and raise ::ArgumentError, "this is an atomic #{
                }field - cannot take more than one argument"
              if a.length.nonzero?
                b and raise ::ArgumentError, "args and block are mutex"
                @set[ i, :value, a.fetch( 0 ) ]
              elsif b
                @set[ i, :proc, b ]
              else
                raise ::ArgumentError, "must have either args or block #{
                  }for `#{ fld.normal }`."
              end
            end
          end

          self
        end ]
        self
      end
    end

    def self.dynamic *a
      a.each do |i, v|
        const = const_ i
        const_set const, v

        define_method i do
          self.class.const_get const
        end
      end
    end

    def self.const_ i
      :"#{ i.to_s.upcase }_"
    end

    def self.enhance mod, blk
      arr = ::Array.new self::FIELD_A_.length
      cnd = self::CONDUIT_.new arr
      cnd.instance_exec( & blk )
      flush mod, arr
    end

    H_ = {
      value: -> fld, x do
        _, const, ivar = fld.to_a
        -> do
          if instance_variable_defined? ivar
            instance_variable_get ivar
          else
            self.class.const_get( const )
          end
        end
      end,
      proc: -> fld, f do
        _, const, ivar = fld.to_a
        -> do
          if instance_variable_defined? ivar
            instance_variable_get ivar
          else
            self.class.const_get( const ).call
          end
        end
      end
    }.freeze

    def self.flush mod, arr
      kls = if mod.const_defined? self::CONST_, false
        mod.const_get self::CONST_, false
      else
        mod.const_set self::CONST_, ::Class.new( self::SUPERCLASS_ )
      end
      arr.each_with_index do | (type, x), idx |
        fld = self::FIELD_A_.fetch idx
        if kls.const_defined? fld.const, false
          raise "already initialized constant #{ kls }::#{ fld.const }"
        end
        kls.const_set fld.const, x  # be it proc or value
        kls.send :define_method, fld.normal, & H_.fetch( type )[ fld, x ]
        kls.send :attr_writer, fld.normal
      end
      nil
    end
  end
end
