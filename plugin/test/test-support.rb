require 'skylab/plugin'
require 'skylab/test_support'

module Skylab::Plugin::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

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

  Expect_Event = -> tcc do

    Callback_.test_support::Expect_Event[ tcc ]

    tcc.send :define_method, :black_and_white_expression_agent_for_expect_event do
      Home_.lib_.brazen::API.expression_agent_instance
    end

    NIL_
  end

  Memoizers = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  Home_ = ::Skylab::Plugin

  Callback_ = Home_::Callback_

  Callback_::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  NIL_ = nil
  TS_ = self
end
