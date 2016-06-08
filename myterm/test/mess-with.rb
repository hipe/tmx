module Skylab::MyTerm::TestSupport

  class Mess_With < Common_::Actor::Monadic

    # -

      def initialize mutatee
        @_mutatee = mutatee
      end

      def execute
        self  # there is no `flush` - you just mutate
      end

      def replace_with_partially_stubbed_proxy sym, & edit

        original_getter = @_mutatee.method sym

        redefine_as_memoized sym do

          _original_object = original_getter[]

          _original_object or self._SANITY

          Make_dynamic_stub_proxy.call _original_object, & edit
        end
      end

      def redefine_as_memoized sym, & repl

        @_mutatee.send :define_singleton_method, sym, Lazy_.call( & repl )
        NIL_
      end

    # -
    class Make_dynamic_stub_proxy < Common_::Actor::Monadic

      def initialize real_object, & edit
        if ! real_object
          self._SANITY
        end
        @_real_object = real_object
        @_edit_p = edit
      end

      def execute

        cls = ::Class.new ::BasicObject

        real_object = @_real_object

        cls.send :define_method, :method_missing do | m, * a, & p |

          real_object.send m, * a, & p

        end

        @_cls = cls

        @_stubbed_proxy = cls.new

        @_edit_p[ self ]

        @_stubbed_proxy
      end

      def if_then m, * args, & p

        if_then_maybe m do | * args_, & p_ |
          if args == args_
            p
          end
        end
      end

      def if_then_maybe m, & match_p

        real = @_real_object

        @_cls.send :define_method, m do | * args_, & p_ |

          then_p = match_p[ * args_, & p_ ]
          if then_p
            then_p[]
          else
            real.send m, * args_, & p_
          end
        end
        NIL_
      end
    end
  end
end
