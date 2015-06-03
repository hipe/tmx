require_relative '../core'

module Skylab::Callback::TestSupport

  class << self

    def call_digraph_listeners_spy *a

      if a.length.zero?
        TS_::Call_Digraph_Listeners_Spy__
      else
        TS_::Call_Digraph_Listeners_Spy__.new_via_iambic a
      end
    end
  end  # >>

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  TestSupport_ = Autoloader_.require_sidesystem :TestSupport

  extend TestSupport_::Quickie

  TestSupport_::Regret[ TS_ = self ]

  module InstanceMethods

    def debug!
      @do_debug = true ; nil
    end
    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    define_method :fixtures_dir_pn, ( Callback_.memoize do
      Callback_::TestSupport.dir_pathname.join 'fixtures'
    end )
  end

  LIB_ = ::Object.new
  class << LIB_

    def list_lib
      Callback_.lib_.basic::List
    end
  end

  # ~ singles

  EMPTY_A_ = Callback_::EMPTY_A_
  KEEP_PARSING_ = true
  NEWLINE_ = "\n".freeze
  NIL_ = nil

  # ~ give these to the children

  module Constants
    Callback_ = Callback_
    EMPTY_A_ = EMPTY_A_
    KEEP_PARSING_ = KEEP_PARSING_
    TestSupport_ = TestSupport_
  end

  Autoloader_[ self, Callback_.dir_pathname.join( 'test' ).to_path ]
end
