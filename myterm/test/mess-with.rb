module Skylab::MyTerm::TestSupport

  class Mess_With

    # (mocking/stubbing hax)

    class << self
      def _call x, & edit
        new( x )._edit_by( & edit )
      end
      alias_method :[], :_call
      alias_method :call, :_call
      private :new
    end  # >>

    def initialize x
      @_x = x
    end

    def _edit_by & edit
      edit[ self ]
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

    class Make_dynamic_stub_proxy

      class << self
        def _call real_object, & edit
          o = new real_object
          edit[ o ]
          o.finish
        end
        alias_method :[], :_call
        alias_method :call, :_call
      end  # >>

      def initialize real_object

        @_real_object = real_object

        cls = ::Class.new ::BasicObject

        cls.send :define_method, :method_missing do | m, * a, & p |

          real_object.send m, * a, & p

        end

        @_cls = cls

        @_stubbed_proxy = cls.new
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
