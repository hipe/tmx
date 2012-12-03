require_relative '../test-support'

module Skylab::TanMan::TestSupport::CLI
  ::Skylab::TanMan::TestSupport[ CLI_TestSupport = self ]

  include CONSTANTS # so we can say TanMan in the spec's module

  module ModuleMethods
    include CONSTANTS

    include MetaHell::Klass::Creator::ModuleMethods
  end

  module InstanceMethods
    include CONSTANTS
    extend MetaHell::Let

    include MetaHell::Klass::Creator::InstanceMethods

    let( :meta_hell_anchor_module ) { CLI_TestSupport }


    let :action do
      k = klass
      if ! k.ancestors.include? TanMan::CLI::Action
        fail "sanity - klass looks funny: #{ k }"
      end
      client or fail 'client?'
      o = k.new client
      o
    end



    let :client do
      self.do_debug = true
      o = TanMan::CLI.new
      o.program_name = 'tanmun'
      ioa = Headless::TestSupport::IO_Adapter_Spy.new
      ioa.debug = -> { do_debug }
      o.send :io_adapter=, ioa
      o
    end

  end
end
