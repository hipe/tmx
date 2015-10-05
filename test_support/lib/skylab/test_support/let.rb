module Skylab::TestSupport

  # apologies to rspec : it has many great things with let() being the greatest

  module Let

    # minimal memoizer.

    class << self

      def extended mod
        self._SOMEBODY_IS_PULLING_IN_LET_THE_OLD_WAY  # #todo
      end

      def [] cls

        cls.send :define_singleton_method, :let, LET_METHOD

        cls.send :define_method, :memoized_, MEMOIZED_METHOD

        cls.send :alias_method, :__memoized, :memoized_  # eek, compat with r.s

        NIL_
      end
    end  # >>

    LET_METHOD = -> name_symbol, & initial_value_p do

      define_method name_symbol do

        __memoized.fetch name_symbol do | k |

          __memoized[ k ] = instance_exec( & initial_value_p )
        end
      end
    end

    MEMOIZED_METHOD = -> do

      @memoized_ ||= {}
    end
  end
end
