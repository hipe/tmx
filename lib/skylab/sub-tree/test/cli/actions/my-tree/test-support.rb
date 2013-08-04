require_relative '../core'

require 'skylab/headless/test/test-support'

module Skylab::MyTree::TestSupport
  ::Skylab::TestSupport::Regret[ self ]


  class FUN # #abuse
    expect_text = -> emission do
      txt = emission.payload_x
      ::String === txt or fail "expected text"
      txt
    end

    define_singleton_method :expect_text do expect_text end
  end

  module CONSTANTS
    FUN = FUN
    Headless = ::Skylab::Headless
    MetaHell = ::Skylab::MetaHell
    MyTree = ::Skylab::MyTree
    TestSupport = ::Skylab::TestSupport  # le balls
  end

  include CONSTANTS # so we can use them in the spec body

  extend TestSupport::Quickie

  module InstanceMethods

    include CONSTANTS             # for immediately below, and others

    extend MetaHell::Let

    attr_reader :debug

    def debug!
      @debug = true
    end

    def invoke *argv
      me = self ; ioa = nil
      client = MyTree::CLI.new.instance_exec do
        @program_name = 'mt'
        @io_adapter = Headless::TestSupport::IO_Adapter_Spy.new build_pen
        @io_adapter.debug = -> { me.debug }
        ioa = @io_adapter
        self
      end
      exit_result = client.invoke argv
      @emission_queue = ioa.delete_emission_a
      exit_result
    end

    -> do  # `line`

      unstyle = Headless::CLI::Pen::FUN.unstyle

      expect_text = FUN.expect_text

      define_method :line do
        e = @emission_queue.shift
        if e
          unstyle[ expect_text[ e ] ]
        end
      end
    end.call
  end
end
