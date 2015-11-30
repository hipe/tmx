module Skylab::TestSupport

  class Library

    # implement the DSL with `PUBLIC` for test library nodes that are exposed

    def initialize close_lib, far_lib=close_lib

      @_public = -> do
        cache = {}
        -> sym do
          cache.fetch sym do
            x = @_protected[ sym ]
            if x.const_defined? :PUBLIC, false
              yes = x.const_get :PUBLIC, false
            end
            if yes
              cache[ sym ] = x
              x
            else
              raise ::NameError, __say_etc( sym, far_lib )
            end
          end
        end
      end.call

      lookup = nil
      @_protected = -> do
        cache = {}
        -> sym do
          cache.fetch sym do
            x = lookup[ sym ]
            cache[ sym ] = x
            x
          end
        end
      end.call

      lookup = -> sym do
        s = sym.id2name
        const = :"#{ s[ 0 ].upcase }#{ s[ 1 .. -1 ] }"
        if close_lib.const_defined? const, false
          close_lib.const_get const
        else
          Home_.fancy_lookup sym, far_lib
        end
      end
    end

    def public_library sym
      @_public[ sym ]
    end

    def protected_library sym
      @_protected[ sym ]
    end

    def __say_etc sym, far_lib
      "#{ far_lib.name } `#{ sym }` is not public but can be made public #{
        }by setting in it a constant `PUBLIC` with a true-ish value."
    end
  end
end
