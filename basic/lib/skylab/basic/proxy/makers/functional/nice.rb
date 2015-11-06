module Skylab::Basic

  # ->

    class Proxy::Makers::Functional

      class Nice < self

        # as "functional" but has a ready-made implementations for `class`
        # and `inspect` (which both reveal this to be a proxy and not the
        # downstream implementor).
        #
        # also, the arguments that `initialize` receives constitute a sparse
        # positional arglist produced from the hash-like args of the
        # caller, as a mandatory convenience.

        class << self

          def new * a, & convenience_p

            cls = make_ a

            cls.send :define_singleton_method, :new do | * x_a |

              pair_stream = Try_convert_iambic_to_pair_stream_[ x_a ]

              bx = const_get CONST_

              arglist = ::Array.new bx.length

              while pair = pair_stream.gets
                arglist[ bx.index( pair.name_symbol ) ] = pair.value_x
              end

              o = orig_new_( * arglist )  # ick

              _CLASS = self

              _sc = class << o ; self end

              _sc.send :define_method, :class do
                _CLASS
              end

              o
            end

            convenience_p and cls.class_exec( & convenience_p )

            cls
          end
        end  # >>

        def initialize * p_a
          @__proxy_kernel__ = Kernel_.new __functional_proxy_property_box__
          @__proxy_kernel__.process_arglist_fully p_a
        end

        def inspect
          _a = self.class.const_get( CONST_ ).a_
          "#<#{ self.class.name } #{ _a * ', ' }>"
        end
      end
    end
  # <-
end
