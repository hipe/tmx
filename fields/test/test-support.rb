require 'skylab/fields'
require 'skylab/test_support'

module Skylab::Fields::TestSupport

  class << self
    def [] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  -> do

    cache = {}

    lookup = -> k do

      const = Common_::Name.via_variegated_symbol( k ).as_const

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

  module ModuleMethods___

    define_method :use, Use_method__

    def subject & p
      memoize_ :subject, & p
    end

    def memoize_ sym, & p
      define_method sym, Common_.memoize( & p )
    end

    define_method :dangerous_memoize_, TestSupport_::DANGEROUS_MEMOIZE
  end

  module InstanceMethods___

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

    def common_expression_agent_
      Home_.lib_.brazen::API.expression_agent_instance
    end

    def state_for_expect_event
      state_
    end
  end

  Build_next_integer_generator_starting_after = -> d do

    -> do
      d += 1
    end
  end

  Home_ = ::Skylab::Fields

  Common_ = Home_::Common_

  Expect_Event = -> tcm do

    Common_.test_support::Expect_Event[ tcm ]
  end

  Memoizer_Methods = -> tcc do

    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Lazy_ = Home_::Lazy_
  NIL_ = nil
  TS_ = self
end

Skylab::TestSupport::Quickie.enable_kernel_describe  # for > 10 legacy files
