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

              pair_stream = Proxy__PairStream_via_ArgumentArray_[ x_a ]

              bx = const_get MEMBER_BOX_CONST_

              arglist = ::Array.new bx.length

              while pair = pair_stream.gets
                arglist[ bx.offset_of pair.name_symbol ] = pair.value_x
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
          @__proxy_implementation__ = ProxyImplementation_via_.call_by do |o|
            o.argument_value_array = p_a
            o.association_box = __functional_proxy_association_box__
          end
        end

        def inspect
          _a = self.class.const_get( MEMBER_BOX_CONST_ ).a_
          "#<#{ self.class.name } #{ _a * ', ' }>"
        end
      end
    end
  # <-
end
