module Skylab::MyTerm::TestSupport

  class Mess_With < Callback_::Actor::Monadic

    # (mocking/stubbing hax)

    def initialize x, & edit
      @_x = x
      @_edit_p = edit
    end

    def execute
      @_edit_p[ self ]
      NIL_
    end

    def replace_with_dynamic_stub m, & edit

      _real_object = @_x.send m

      o = Make_dynamic_stub_proxy.new _real_object
      edit[ o ]
      stub_object = o.finish

      redefine m do
        stub_object
      end
      NIL_
    end

    def redefine m, & p
      @_x.send :define_singleton_method, m, & p
      NIL_
    end

    class Make_dynamic_stub_proxy < Callback_::Actor::Monadic

      def initialize real_object, & edit
        @_real_object = real_object
        @_edit_p = edit
      end

      def execute

        cls = ::Class.new ::BasicObject

        cls.send :define_method, :method_missing do | m, * a, & p |

          real_object.send m, * a, & p

        end

        @_cls = cls

        @_stubbed_proxy = cls.new

        @_edit[ self ]

        finish
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

      def finish
        @_stubbed_proxy
      end
    end
  end
end
