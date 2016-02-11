require 'skylab/human'
require 'skylab/test_support'

module Skylab::Human::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  extend TestSupport_::Quickie

  TestSupport_::Quickie.enable_kernel_describe

  TS_Joist_ = -> tcc do  # #until after [#sa-019]
    tcc.send :define_singleton_method, :use, Use_method__
  end

    Use_method__ = -> do

      cache_h = {}

      -> k do

        ( cache_h.fetch k do
          x = TestSupport_.fancy_lookup k, TS_
          cache_h[ k ] = x
          x
        end )[ self ]
        NIL_
      end
    end.call

  module ModuleMethods

    define_method :use, Use_method__

    def memoize_ sym, & p
      define_method sym, Callback_.memoize( & p )
    end
  end

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  # --

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # --

  Home_ = ::Skylab::Human

  Callback_ = Home_::Callback_
  EMPTY_A_ = [].freeze
  NIL_ = nil
end
