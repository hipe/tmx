require_relative '../test-support'
require 'skylab/callback/test/test-support'  # visiting! move up whenever

module Skylab::Porcelain::TestSupport::Bleeding

  ::Skylab::Porcelain::TestSupport[ Bleeding_TestSupport = self ] # #regret

  module CONSTANTS
    Callback_TestSupport_ = Callback_::TestSupport
  end

  include CONSTANTS

  TestLib_ = TestLib_

  module ModuleMethods
    extend TestLib_::Module_creator[]
    include TestLib_::Class_creator[]

    include CONSTANTS

    def base_module!
      (const = constantize description) !~ /\A[A-Z][_a-zA-Z0-9]*\z/ and fail("oops: #{const.inspect}")
      _last = 0
      let(:base_module) { ::Skylab::Porcelain::Bleeding.const_set("#{const}#{_last += 1}", Module.new) }
    end

    def with_action action_token
      once = -> do
        box_const = constantize ns_token
        leaf_const = constantize action_token
        accessor = "#{ box_const }__#{ leaf_const }"
        send accessor # #kick #refactor
        box = send box_const
        ns = Bleeding::Namespace::Inferred.new box # #app-refactor
        live = ns.build Callback_TestSupport_::Call_Digraph_Listeners_Spy.new( :debug )
        kls = live.fetch action_token
        once = -> { kls }
        kls
      end
      let(:fetch) { instance_exec(& once ) }
      let(:subject) { fetch }
    end

    def with_namespace ns_token
      let :ns_token do ns_token end
    end
  end

  module InstanceMethods
    include TestLib_::CLI[]::Pen::Methods
    include CONSTANTS

    attr_reader :base_module

    def build_action_runtime action_token
      _rt = Bleeding::Runtime.new
      _rt.program_name = "KUSTOM-RT-FOR-#{action_token.upcase}"
      _rt.parent = emit_spy
      once = -> do
        const = constantize action_token
        akton = send const
        a = Bleeding::Actions[ [akton], Bleeding::Officious.actions ]
        once = -> { a }
        a
      end
      _rt.singleton_class.send(:define_method, :actions) { once.call }
      _rt.fetch(action_token)
    end

    def emit_spy
      @emit_spy ||= Callback_TestSupport_::Call_Digraph_Listeners_Spy.new(
        :do_debug_proc, -> { do_debug } )
    end
  end
end

if defined? ::RSpec            # sometimes we load test-support without loading
  require_relative 'for-rspec' # rspec e.g. to check for warnings or, like,
end                            # visual tests or something
