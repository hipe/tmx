require_relative '../test-support'

module Skylab::TanMan::TestSupport::CLI

  ::Skylab::TanMan::TestSupport[ CLI_TestSupport = self ]

  include CONSTANTS # so we can say TanMan in the spec's module

  extend TestSupport::Quickie

  module ModuleMethods

    include CONSTANTS

    include MetaHell::Class::Creator::ModuleMethods
  end

  module InstanceMethods

    include CONSTANTS

    extend MetaHell::Let

    include MetaHell::Class::Creator::InstanceMethods

    def meta_hell_anchor_module
      CLI_TestSupport::SANDBOX
    end

    let :action do
      k = klass
      if ! k.ancestors.include? TanMan::CLI::Action
        fail "sanity - klass looks funny: #{ k }"
      end
      client or fail 'client?'
      o = k.new client
      o
    end

    let :cli do
      spy = output
      o = TanMan::CLI.new nil, spy.for(:paystream), spy.for(:infostream)
      o.program_name = 'ferp'
      o
    end

    let :client do
      o = TanMan::CLI.new
      o.program_name = 'tanmun'
      ioa = Headless::TestSupport::IO_Adapter_Spy.new
      ioa.debug = -> { do_debug }
      o.send :io_adapter=, ioa
      o
    end
  end

  module SANDBOX
    # do not touch! (we got bit before when we had `Actions` both as a module
    # here and in tests doh!)
  end
end
