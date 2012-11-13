require_relative '../test-support'
require_relative '../../core'
require 'skylab/headless/core'

module Skylab::Porcelain::Bleeding::TestSupport
  Bleeding = ::Skylab::Porcelain::Bleeding
  Porcelain = ::Skylab::Porcelain
  class SimplifiedEvent < Struct.new(:type, :message) # hack for prettier dumps ick!
    def string
      "#{type.inspect} #{message.inspect}"
    end
  end

  class ::RSpec::Matchers::DSL::Matcher
    include ::Skylab::Porcelain::En::Number
  end

  class MyEmitSpy < ::Skylab::TestSupport::EmitSpy
    include Porcelain::TiteColor # unstylize
    def initialize &b
      unless block_given?
        b = ->(k, s) { [k, unstylize(s)].inspect }
      end
      super(&b)
    end
    def program_name
      'pergrerm'
    end
  end

  MUSTACHE_RX = ::Skylab::Headless::Constants::MUSTACHE_RX
  last_number = 0
  BUILD_NAMESPACE_RUNTIME = ->(_) do
    @base_module = ::Module.new
    ::Skylab::Porcelain::Bleeding.const_set("Xyzzy#{last_number += 1}", @base_module)
    @nermsperce = m = modul(:MyActions, &namespace_body)
    m = modul(:MyActions, &namespace_body)
    ns = Bleeding::NamespaceInferred.new(m)
    rt = MyEmitSpy.new
    # ns.build(rt).object_id == ns.object_id or fail("handle this")
    [ns, rt]
  end
  module ModuleMethods
    include ::Skylab::MetaHell::ModulCreator
    include ::Skylab::MetaHell::KlassCreator
    include ::Skylab::Autoloader::Inflection::Methods
    def base_module!
      (const = constantize description) !~ /\A[A-Z][_a-zA-Z0-9]*\z/ and fail("oops: #{const.inspect}")
      _last = 0
      let(:base_module) { ::Skylab::Porcelain::Bleeding.const_set("#{const}#{_last += 1}", Module.new) }
    end
    def events &specify_body
      specify(&specify_body)
      tok = @last_token
      once = ->(_) do
        ns, rt = instance_eval(&BUILD_NAMESPACE_RUNTIME)
        ns.find(tok) { |o| o.on_error { |e| rt.emit(SimplifiedEvent.new(e.type, unstylize(e.message))) } }
        _use = rt.stack
        (once = ->(_) { _use }).call(nil)
      end
      let(:subject) { instance_eval(&once) }
    end
    def namespace &b
      let(:namespace_body) { b }
    end
    def result &specify_body
      tok = @last_token
      once = ->(_) do
        ns, rt = instance_eval(&BUILD_NAMESPACE_RUNTIME)
        _res = ns.find(tok) { |o| o.on_error { |e| $stderr.puts("EXpecting no events here (xyzzy) #{e}") } }
        (once = ->(_) { _res }).call(nil)
      end
      let(:subject) { instance_eval(&once) }
      specify do
        instance_eval(&once) # this must be run before the body of the specify block is evaluated
        instance_exec(&specify_body)
      end
    end
    def token tok
      @last_token = tok
    end
    def with_action action_token
      once = ->(_) do
        send("#{constantize ns_token}__#{constantize action_token}") # call the creator
        action = Bleeding::NamespaceInferred.new(base_module.const_get(constantize ns_token)).
          build(MyEmitSpy.new.debug!).fetch(action_token)
        instance_eval(& (once = ->(_) { action }))
      end
      let(:fetch) { instance_eval(&once) }
      let(:subject) { fetch }
    end
    def with_namespace token
      let(:ns_token) { token }
    end
  end
  module InstanceMethods
    include ::Skylab::Autoloader::Inflection::Methods # constantize
    include ::Skylab::MetaHell::ModulCreator::InstanceMethods
    include ::Skylab::MetaHell::KlassCreator::ExtensorInstanceMethods
    include ::Skylab::Porcelain::TiteColor # unstylize
    attr_reader :base_module
    def build_action_runtime action_token
      _rt = Bleeding::Runtime.new
      _rt.program_name = "KUSTOM-RT-FOR-#{action_token.upcase}"
      _rt.parent = emit_spy
      once = ->() do
        akton = send(constantize action_token)
        a = Bleeding::Actions[ [akton], Bleeding::Officious.actions ]
        (once = ->{ a }).call
      end
      _rt.singleton_class.send(:define_method, :actions) { once.call }
      _rt.fetch(action_token)
    end
    def emit_spy
      @emit_spy ||= MyEmitSpy.new
    end
    def namespace
      @nermsperce
    end
  end
end

if defined? ::RSpec            # sometimes we load test-support without loading
  require_relative 'for-rspec' # rspec e.g. to check for warnings or, like,
end                            # visual tests or something
