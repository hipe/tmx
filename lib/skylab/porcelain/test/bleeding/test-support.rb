require_relative '../test-support'
require_relative '../../core'
require 'skylab/headless/core'

module Skylab::Porcelain::TestSupport::Bleeding
  Parent_ = ::Skylab::Porcelain::TestSupport # #ts-002
  Parent_[ self ] # #regret
  Bleeding_TestSupport = self # courtesy

  module CONSTANTS # #ts-002
    include Parent_::CONSTANTS
    MUSTACHE_RX = Headless::CONSTANTS::MUSTACHE_RX
  end

  class Event_Simplified < ::Struct.new :type, :message
    # hack for prettier dumps whateveuh
    def string
      "#{type.inspect} #{message.inspect}"
    end
  end

  include CONSTANTS # have it here so it's seen in my child modules?
  Porcelain = Porcelain

  class My_EmitSpy < ::Skylab::TestSupport::EmitSpy
    include Porcelain::TiteColor::Methods # unstylize
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

  module CONSTANTS
    Event_Simplified = Event_Simplified
    My_EmitSpy = My_EmitSpy
  end

  module ModuleMethods
    extend ::Skylab::MetaHell::Modul::Creator
    include ::Skylab::MetaHell::Klass::Creator
    include ::Skylab::Autoloader::Inflection::Methods
    def base_module!
      (const = constantize description) !~ /\A[A-Z][_a-zA-Z0-9]*\z/ and fail("oops: #{const.inspect}")
      _last = 0
      let(:base_module) { ::Skylab::Porcelain::Bleeding.const_set("#{const}#{_last += 1}", Module.new) }
    end

    -> do # mad hax to clean up later #refactor

      last_number = 0

      namespace_and_runtime = -> do
        mod = ::Module.new
        Bleeding_TestSupport.const_set "Xyzzy#{ last_number += 1 }", mod
        singleton_class.send(:define_method, :meta_hell_anchor_module) { mod }
        @nermsperce = m = modul!(:MyActions, & _namespace_body)
        ns = Bleeding::NamespaceInferred.new(m)
        rt = My_EmitSpy.new
        # ns.build(rt).object_id == ns.object_id or fail("handle this")
        [ns, rt]
      end

      define_method :events do |&specify_body|
        specify(& specify_body)
        tok = @last_token
        once = -> do
          ns, rt = instance_exec(& namespace_and_runtime)
          ns.find tok do |o|
            o.on_error do |e|
              rt.emit( Event_Simplified.new e.type, unstylize(e.message) )
            end
          end
          _use = rt.stack
          once = -> { _use }
          _use
        end

        let(:subject) { instance_exec(& once) }
      end

      define_method :result do |&specify_body|
        tok = @last_token
        once = -> do
          ns, rt = instance_exec(& namespace_and_runtime)
          _res = ns.find tok do |o|
            o.on_error do |e|
              $stderr.puts "EXpecting no events here (xyzzy) #{e}"
            end
          end
          once = -> { _res }
          _res
        end

        let(:subject) { instance_exec(& once) }

        specify do
          instance_exec(& once)           # this must be run before the body
          instance_exec(& specify_body)   # of the specify block is evaluated
        end
      end

    end.call
    def namespace &b
      let( :_namespace_body ) { b }
    end
    def token tok
      @last_token = tok
    end
    def with_action action_token
      once = ->(_) do
        box_const = constantize ns_token
        leaf_const = constantize action_token
        accessor = "#{box_const}__#{leaf_const}"
        send accessor # #kick #refactor
        box = send box_const
        ns = Bleeding::NamespaceInferred.new box # #app-refactor
        what = ns.build My_EmitSpy.new.debug! # #app-refactor
        action = what.fetch action_token
        once = -> { action }
        action
      end
      let(:fetch) { instance_eval(&once) }
      let(:subject) { fetch }
    end
    def with_namespace token
      let(:ns_token) { token }
    end
  end
  module InstanceMethods
    include Porcelain::TiteColor::Methods
    include CONSTANTS
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
      @emit_spy ||= My_EmitSpy.new
    end
    def namespace
      @nermsperce
    end
  end
end

if defined? ::RSpec            # sometimes we load test-support without loading
  require_relative 'for-rspec' # rspec e.g. to check for warnings or, like,
end                            # visual tests or something
