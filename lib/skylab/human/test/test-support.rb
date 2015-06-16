require_relative '../core'

Skylab::Human::Autoloader_.require_sidesystem :TestSupport

module Skylab::Human::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  TestSupport_::Quickie.enable_kernel_describe

  module ModuleMethods

    define_method :use, -> do

      cache_h = {}

      -> sym do

        ( cache_h.fetch sym do

          cache_h[ sym ] = Hu_.lib_.plugin::Bundle::Fancy_lookup[ sym, TS_ ]

        end )[ self ]
        NIL_
      end
    end.call

    def memoize_ sym, & p

      define_method sym, Hu_::Callback_.memoize( & p )
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
  Hu_ = ::Skylab::Human
  NIL_ = nil
end
