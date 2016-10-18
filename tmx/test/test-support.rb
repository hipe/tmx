require 'skylab/tmx'
require 'skylab/test_support'

module Skylab::TMX::TestSupport

  class << self
    def [] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  module ModuleMethods___

    define_method :use, -> do
      cache = {}
      -> sym do
        ( cache.fetch sym do

          const = Common_::Name.via_variegated_symbol( sym ).as_const

          x = if TS_.const_defined? const
            TS_.const_get const
          else
            TestSupport_.fancy_lookup sym, TS_
          end
          cache[ sym ] = x
          x
        end )[ self  ]
      end
    end.call

    define_method :dangerous_memoize_, TestSupport_::DANGEROUS_MEMOIZE

    def memoize_ sym, & p
      define_method sym, Lazy_.call( & p )
    end
  end

  module InstanceMethods___

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  Common_ = ::Skylab::Common
  Home_ = ::Skylab::TMX

  # ==

    Memoizer_Methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end

  # ==

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  NIL_ = nil
  NOTHING_ = nil
  Stream_ = Home_::Stream_
  TS_ = self
end
