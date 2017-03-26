require 'skylab/human'
require 'skylab/test_support'

module Skylab::Human::TestSupport

  class << self
    def [] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  TestSupport_::Quickie.enable_kernel_describe

  # -
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
  # -

  module ModuleMethods___

    define_method :use, Use_method__

    def memoize_ sym, & p
      define_method sym, Common_.memoize( & p )
    end
  end

  module InstanceMethods___

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def common_expag_
      Home_.lib_.brazen::API.expression_agent_instance
    end
  end

  # --

  module NLP_EN_ ; class << self
    def POS_lib
      Home_::NLP::EN::POS
    end
    def sexp_lib
      Home_::NLP::EN::Sexp
    end
    def lib
      Home_::NLP::EN
    end
  end ; end

  Expect_Event = -> tcc do
    Common_.test_support::Expect_Emission[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # --

  Home_ = ::Skylab::Human

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Common_ = Home_::Common_
  EMPTY_A_ = [].freeze
  Lazy_ = Home_::Lazy_
  NEWLINE_ = "\n"
  NIL_ = nil
  NOTHING_ = Home_::NOTHING_
  TS_ = self
  UNRELIABLE_ = :_unre_
end
