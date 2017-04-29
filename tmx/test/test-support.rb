require 'skylab/tmx'
require 'skylab/test_support'

module Skylab::TMX::TestSupport

  class << self

    def begin_CLI_expectation_client
      o = Zerk_lib_[].test_support::Non_Interactive_CLI::Fail_Early::
        Client_for_Expectations_of_Invocation.new
      o.program_name_string_array = %w(xmt)
      o.subject_CLI_by { Home_::CLI }
      o
    end

    def [] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end

  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

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

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  module InstanceMethods___

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  Home_ = ::Skylab::TMX
  Autoloader_ = Home_::Autoloader_
  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  # ==

    Memoizer_Methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end

    Non_Interactive_CLI_Fail_Early = -> tcc do
      Zerk_lib_[].test_support::Non_Interactive_CLI::Fail_Early[ tcc ]
    end

  # --

  Zerk_test_support_ = Lazy_.call do
    Zerk_lib_[].test_support
  end

  # --

  MONADIC_EMPTINESS_ = Home_::MONADIC_EMPTINESS_
  NIL_ = nil
  NOTHING_ = Home_::NOTHING_
  Stream_ = Home_::Stream_
  TS_ = self
  Zerk_lib_ = Home_::Zerk_lib_
end
