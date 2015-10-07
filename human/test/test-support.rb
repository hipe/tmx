require 'skylab/human'
require 'skylab/test_support'

module Skylab::Human::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  extend TestSupport_::Quickie

  TestSupport_::Quickie.enable_kernel_describe

  module ModuleMethods

    define_method :use, -> do

      cache_h = {}

      -> sym do

        ( cache_h.fetch sym do

          cache_h[ sym ] = TestSupport_.fancy_lookup sym, TS_

        end )[ self ]
        NIL_
      end
    end.call

    def memoize_ sym, & p

      define_method sym, Home_::Callback_.memoize( & p )
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

  EMPTY_A_ = [].freeze
  Home_ = ::Skylab::Human
  NIL_ = nil
end
