require 'skylab/plugin'
require 'skylab/test_support'

module Skylab::Plugin::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, The_use_method___
      tcc.include Instance_Methods__
    end

    cache = {}
    define_method :lib_ do | sym |

      cache.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
    end
  end  # >>

  Home_ = ::Skylab::Plugin
  Common_ = Home_::Common_
  Autoloader_ = Common_::Autoloader
  Lazy_ = Common_::Lazy

  # -- module methods and instance methods

    The_use_method___ = -> sym do
      TS_.lib_( sym )[ self ]
    end

  module Instance_Methods__

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  # -- test support enhancement modules

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Want_Event = -> tcc do

    Common_.test_support::Want_Emission[ tcc ]

    NIL_
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # -- plain old functions

  Zerk_lib_ = Lazy_.call do
    Autoloader_.require_sidesystem :Zerk
  end

  BRAZEN = Lazy_.call do
    _ = Autoloader_.require_sidesystem :Brazen
    _  # #hi. #todo
  end

  # -- these

  ACHIEVED_ = true
  NIL_ = nil
  NIL = nil  # open [#sli-016.C]
  NOTHING_ = Home_::NOTHING_
  TS_ = self
end
