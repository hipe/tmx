require 'skylab/plugin'
require 'skylab/test_support'

module Skylab::Plugin::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, The_use_method___
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

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  Expect_Event = -> tcm do

    Callback_.test_support::Expect_Event[ tcm ]

    tcm.send :define_method, :black_and_white_expression_agent_for_expect_event do
      Home_.lib_.brazen::API.expression_agent_instance
    end

    NIL_
  end

  Home_ = ::Skylab::Plugin

  Callback_ = Home_::Callback_

  Callback_::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  NIL_ = nil
  TS_ = self
end
