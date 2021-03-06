require 'skylab/common'

module Skylab::Common::TestSupport

  class << self

    def [] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end

    def call_digraph_listeners_spy *a

      if a.length.zero?
        TS_::Call_Digraph_Listeners_Spy__
      else
        TS_::Call_Digraph_Listeners_Spy__.via_iambic a
      end
    end
  end  # >>

  Home_ = ::Skylab::Common
  Autoloader_ = Home_::Autoloader
  Lazy_ = Home_::Lazy

  TestSupport_ = Autoloader_.require_sidesystem :TestSupport
  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  module ModuleMethods___

    define_method :use, -> do

      cache = {}

      cache[ :memoizer_methods ] = -> tcc do  # until etc.
        TestSupport_::Memoization_and_subject_sharing[ tcc ]
      end

      cache[ :the_method_called_let ] = -> tcc do
        TestSupport_::Let[ tcc ]
      end

      -> sym do
        ( cache.fetch sym do
          cache[ sym ] = TestSupport_.fancy_lookup sym, TS_
        end )[ self ]
      end
    end.call
  end

  module InstanceMethods___

    def debug!
      @do_debug = true ; nil
    end
    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  # --

  String_IO_ = Lazy_.call do
    require 'stringio'
    ::StringIO
  end

  # --

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = Home_::ACHIEVED_
  EMPTY_A_ = Home_::EMPTY_A_
  KEEP_PARSING_ = true
  NEWLINE_ = "\n".freeze
  NOTHING_ = nil
  NIL_ = nil
  NIL = nil  # open [#sli-016.C]
    TRUE = true  # same
  TS_ = self
  UNABLE_ = false
end
