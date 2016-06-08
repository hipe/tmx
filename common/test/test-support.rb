require 'skylab/common'

module Skylab::Common::TestSupport

  class << self

    def etc_ tcc
      tcc.extend ModuleMethods
      tcc.include InstanceMethods
      NIL_
    end

    def call_digraph_listeners_spy *a

      if a.length.zero?
        TS_::Call_Digraph_Listeners_Spy__
      else
        TS_::Call_Digraph_Listeners_Spy__.new_via_iambic a
      end
    end
  end  # >>

  Home_ = ::Skylab::Common
    Autoloader_ = Home_::Autoloader

  TestSupport_ = Autoloader_.require_sidesystem :TestSupport

  extend TestSupport_::Quickie

  TS_ = self
  TestSupport_::Regret[ self, ::File.dirname( __FILE__ ) ]

  define_method :dangerous_memoize_, TestSupport_::DANGEROUS_MEMOIZE

  module ModuleMethods

    define_method :use, -> do

      cache = {}

      cache[ :memoizer_methods ] = -> tcc do  # until etc.
        TestSupport_::Memoization_and_subject_sharing[ tcc ]
      end

      -> sym do
        ( cache.fetch sym do
          cache[ sym ] = TestSupport_.fancy_lookup sym, TS_
        end )[ self ]
      end
    end.call
  end

  module InstanceMethods

    def debug!
      @do_debug = true ; nil
    end
    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    define_method :fixtures_dir_pn, ( Home_.memoize do
      Home_::TestSupport.dir_pathname.join 'fixtures'
    end )
  end

  LIB_ = ::Object.new
  class << LIB_

    def basic
      Home_.lib_.basic
    end
  end

  # ~ singles

  ACHIEVED_ = Home_::ACHIEVED_
  EMPTY_A_ = Home_::EMPTY_A_
  KEEP_PARSING_ = true
  NEWLINE_ = "\n".freeze
  NIL_ = nil
  UNABLE_ = false

  # ~ give these to the children

  module Constants
    Home_ = Home_
    EMPTY_A_ = EMPTY_A_
    KEEP_PARSING_ = KEEP_PARSING_
    TestSupport_ = TestSupport_
  end
end
