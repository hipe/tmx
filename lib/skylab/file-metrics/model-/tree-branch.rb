module Skylab::FileMetrics

  Model_ = ::Module.new

  class Model_::Tree_Branch < FM_.lib_.basic::Tree.mutable_node::Frugal

    class << self

      alias_method :__orig_new, :new

      def new * sym_a

        ::Class.new( self ).class_exec do

          class << self
            alias_method :new, :__orig_new
          end

          const_set BX__, Callback_::Box.new

          _edit_via_symbols sym_a

          self
        end
      end

      def subclass * sym_a

        ::Class.new( self ).class_exec do

          const_set BX__, const_get( BX__ ).dup

          _edit_via_symbols sym_a

          self
        end
      end

      def _edit_via_symbols sym_a

        bx = const_get BX__, false

        sym_a.each do | sym |

          define_method sym do
            _read sym
          end

          define_method :"#{ sym }=" do | x |
            _write x, sym
          end

          bx.add sym, sym
        end
        NIL_
      end
    end  # >>

    def initialize * a
      super()

      if a.length.zero?
        if _properties.length.nonzero?
          # if there "should be" a userdata hash, nil all of them out
          _init_via_arglist a
        end
      else
        _init_via_arglist a
      end
    end

    def _init_via_arglist a

      h = {}

      bx = _properties

      len = bx.length

      if a.length > len
        raise ::ArgumentError, __say( a, len )
      end

      a.each_with_index do | x, d |

         h[ bx.at_position( d ) ] = x
      end

      ( a.length ... len ).each do | d |
        h[ bx.at_position( d ) ] = nil
      end

      @user_data_h_ = h

      NIL_
    end

    attr_writer :slug  # because you changed the constructor

    def __say x_a, len
      "wrong number of args (#{ x_a.length } for #{ len })"
    end

    def [] k
      @user_data_h_.fetch k
    end

    def _read k
      @user_data_h_.fetch k
    end

    def _write x, k
      _properties.fetch( k )
      @user_data_h_ ||= {}
      @user_data_h_[ k ] = x
      NIL_
    end

    def append_child_ x
      @a or _!
      add @a.length, x
    end

    def _properties
      self.class.const_get BX__
    end

    BX__ = :BX____

  end
end
# :+#tombstone the predecessor to this is HILARIOUS function soup
