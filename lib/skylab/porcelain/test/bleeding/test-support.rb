require_relative '../test-support'
require 'skylab/pub-sub/test/test-support'  # visiting! move up whenever

module Skylab::Porcelain::TestSupport::Bleeding

  ::Skylab::Porcelain::TestSupport[ Bleeding_TestSupport = self ] # #regret

  module CONSTANTS
    PubSub_TestSupport = PubSub::TestSupport
  end

  include CONSTANTS

  module ModuleMethods
    extend MetaHell::Module::Creator
    include MetaHell::Class::Creator
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
        live = ns.build PubSub_TestSupport::Emit_Spy.new.debug! # #app-refactor
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
    include Headless::CLI::Pen::Methods
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
      @emit_spy ||= begin
        es = PubSub_TestSupport::Emit_Spy.new
        es.debug = -> { do_debug }
        es
      end
    end
  end
end

if defined? ::RSpec            # sometimes we load test-support without loading
  require_relative 'for-rspec' # rspec e.g. to check for warnings or, like,
end                            # visual tests or something
