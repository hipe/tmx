require_relative '../core'

module Skylab::Callback::TestSupport

  class << self
    def call_digraph_listeners_spy *a
      if a.length.zero?
        TS_::Call_Digraph_Listeners_Spy__
      else
        TS_::Call_Digraph_Listeners_Spy__.new( * a )
      end
    end
  end

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  module Constants
    Callback_ = Callback_
    TestSupport_ = Callback_::Autoloader.require_sidesystem :TestSupport
  end

  Autoloader_[ self, Callback_.dir_pathname.join( 'test' ) ]

  include Constants

  extend TestSupport_::Quickie

  TestSupport_::Regret[ TS_ = self ]

  TestSupport_ = TestSupport_

  module InstanceMethods

    def debug!
      @do_debug = true ; nil
    end
    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    define_method :fixtures_dir_pn, Callback_.memoize[ -> do
      Callback_::TestSupport.dir_pathname.join 'fixtures'
    end ]
  end
end
