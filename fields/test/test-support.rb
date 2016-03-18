require 'skylab/fields'
require 'skylab/test_support'

module Skylab::Fields::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  class << self

    def [] tcc  # until etc
      tcc.extend self
    end
  end  # >>

  extend TestSupport_::Quickie

  -> do

    cache = {}

    lookup = -> k do

      const = Callback_::Name.via_variegated_symbol( k ).as_const

      if TS_.const_defined? const, false
        TS_.const_get const
      else
        TestSupport_.fancy_lookup k, TS_
      end
    end

    define_singleton_method :require_ do |k|
      cache.fetch k do
        x = lookup[ k ]
        cache[ k ] = x
        x
      end
    end

  end.call

  Use_method__ = -> k do
    TS_.require_( k )[ self ]
  end

  module ModuleMethods

    define_method :use, Use_method__

    def subject & p
      memoize_ :subject, & p
    end

    def memoize_ sym, & p
      define_method sym, Callback_.memoize( & p )
    end

    define_method :dangerous_memoize_, TestSupport_::DANGEROUS_MEMOIZE
  end

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def handle_event_selectively_
      event_log.handle_event_selectively
    end
  end

  Build_next_integer_generator_starting_after = -> d do

    -> do
      d += 1
    end
  end

  Home_ = ::Skylab::Fields

  Callback_ = Home_::Callback_

  Expect_Event = -> tcm do

    Callback_.test_support::Expect_Event[ tcm ]
  end

  Memoizer_Methods = -> tcc do

    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  Lazy_ = Home_::Lazy_
  NIL_ = nil
end

Skylab::TestSupport::Quickie.enable_kernel_describe  # for > 10 legacy files
