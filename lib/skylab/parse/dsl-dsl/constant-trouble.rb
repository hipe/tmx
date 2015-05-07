module Skylab::MetaHell

  class DSL_DSL::Constant_Trouble  # this was test-first driven, covered.

    class << self
      alias_method :orig_new, :new
    end

    Const_ = -> i do
      :"#{ i.to_s.upcase }_"
    end

    class Field__

      def initialize i
        @normal = i
        @formation_ivar = :"@#{ i }_i"
        @internal_value_ivar = :"@#{ i }_x"
        const = Const_[ i ]
        @proc_const = :"#{ const }PROC_"
        @value_const = :"#{ const }VALUE_"
        nil
      end

      attr_reader :normal, :formation_ivar, :internal_value_ivar,
        :proc_const, :value_const

      def at *i_a
        i_a.map { |i| instance_variable_get :"@#{ i }" }
      end
    end

    def self.new const, superclass, field_a

      ::Class.new( self ).class_exec do

        class << self
          alias_method :new, :orig_new
        end

        h = { }
        fld_a = field_a.each_with_index.map do |i, idx|
          h[ i ] = idx
          Field__.new i
        end.freeze
        h.freeze

        dynamic [ :const, const ], [ :superclass, superclass ],
          [ :field_a, fld_a ], [ :shell, ::Class.new.class_exec do

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

    define_singleton_method :const_, & Const_

    def self.enhance mod, blk=nil
      arr = ::Array.new self::FIELD_A_.length
      cnd = self::SHELL_.new arr
      cnd.instance_exec( & blk ) if blk
      flush mod, arr
    end

    Msg_ = -> fld, up=false do
      "cannot resolve a value for \"#{ fld.normal }\" unambiguously when #{
        }both #{ fld.proc_const } and #{ fld.value_const } are defined#{
        }#{ " as constants in a parent module" if up }"
    end

    def self.flush mod, arr
      kls = if mod.const_defined? self::CONST_, false
        mod.const_get self::CONST_, false
      else
        mod.const_set self::CONST_, ::Class.new( self::SUPERCLASS_ )
      end
      arr.each_with_index do | (type, x), idx |
        fld = self::FIELD_A_.fetch idx
        build_resolution_method kls, fld
        build_set_value_method kls, fld
        build_set_proc_method kls, fld
        type and set_value_resolver kls, fld, type, x
      end
      nil
    end

    Method_Defined_ = -> m, kls do
      "cannot use DSL for this field, method already defined - #{ kls }##{ m }"
    end  # we could soften this when needed..

    def self.build_resolution_method kls, fld
      m, ivar_i, ivar_x, proc_const, value_const = fld.at :normal,
        :formation_ivar, :internal_value_ivar, :proc_const, :value_const
      h = {
        proc: -> do
          instance_variable_get( ivar_x ).call
        end,
        value: -> do
          instance_variable_get ivar_x
        end
      }.freeze
      kls.method_defined?( m ) and fail Method_Defined_[ kls, m ]
      # the below is basically "ivars trump self.class constants trump .."
      kls.send :define_method, m do
        if instance_variable_defined? ivar_i and
            (( i = instance_variable_get ivar_i ))
          v = instance_exec( & h.fetch( i ) )
        elsif (( c = self.class )).const_defined? proc_const, false
          c.const_defined? value_const, false and raise Msg_[ fld ]
          p = c.const_get proc_const, false
        elsif c.const_defined? value_const, false
          v = c.const_get value_const, false
        elsif c.const_defined? proc_const
          c.const_defined? value_const and raise Msg_[ fld, true ]
          p = c.const_get proc_const
        elsif c.const_defined? value_const
          v = c.const_get value_const
        end
        p ? p.call : v
      end
      nil
    end

    -> do  # `self.set_value_resolver`
      msg = -> c, fld, kls do
        "can't store `#{ fld.normal }` via DSL when constant is alread #{
          }defined - #{ kls.name }::#{ c }"
      end
      h = {
        proc: -> fld { fld.proc_const },
        value: -> fld { fld.value_const }
      }
      define_singleton_method :set_value_resolver do |kls, fld, type, x|
        c = h.fetch( type ).call fld
        kls.const_defined?( c, false ) and raise msg[ c, fld, kls ]
        kls.const_set c, x
        nil
      end
      nil
    end.call

    def self.build_set_value_method kls, fld
      kls.method_defined?( m = :"#{ fld.normal }=" ) and
        raise Method_Defined_[ m, kls ]
      ivar_i, ivar_x = fld.at :formation_ivar, :internal_value_ivar
      kls.send :define_method, m do |x|
        instance_variable_set ivar_i, :value
        instance_variable_set ivar_x, x  # is result
      end
      nil
    end

    def self.build_set_proc_method kls, fld
      kls.method_defined?( m = :"set_#{ fld.normal }_proc" ) and
        raise Method_Defined_[ m, kls ]
      ivar_i, ivar_x = fld.at :formation_ivar, :internal_value_ivar
      kls.send :define_method, m do |x|
        instance_variable_set ivar_i, :proc
        instance_variable_set ivar_x, x
        nil  # until needed
      end
      nil
    end
  end
end
