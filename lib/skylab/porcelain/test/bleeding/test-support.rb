require_relative '../test-support'
require_relative '../../core'
require 'skylab/headless/core'

module Skylab::Porcelain::TestSupport::Bleeding
  ::Skylab::Porcelain::TestSupport[ Bleeding_TestSupport = self ] # #regret

  module CONSTANTS
    MUSTACHE_RX = Headless::CONSTANTS::MUSTACHE_RX
    self::Bleeding || nil
    self::Porcelain || nil
  end

  include CONSTANTS

  self::Bleeding || nil

  class Event_Simplified < ::Struct.new :stream_name, :message
    # hack for prettier dumps whateveuh
    def string
      "#{stream_name.inspect} #{message.inspect}"
    end
  end


  class EmitSpy < TestSupport::EmitSpy
    include CONSTANTS
    include Headless::CLI::Stylize::Methods # unstylize
    def initialize &block
      block ||= -> k, s { [ k, unstylize( s ) ].inspect }
      super(& block)
    end
    def program_name
      'pergrerm'
    end
  end

  module CONSTANTS
    Event_Simplified = Event_Simplified
  end

  module ModuleMethods
    extend MetaHell::Modul::Creator
    include MetaHell::Klass::Creator
    include Autoloader::Inflection::Methods
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
        ns = Bleeding::Namespace::Inferred.new(m)
        rt = EmitSpy.new
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
              rt.emit( Event_Simplified.new e.stream_name, unstylize(e.message) )
            end
          end
          _use = rt.emitted
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
        ns = Bleeding::Namespace::Inferred.new box # #app-refactor
        what = ns.build EmitSpy.new.debug! # #app-refactor
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
    include Headless::CLI::Stylize::Methods
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
      @emit_spy ||= EmitSpy.new
    end
    def namespace
      @nermsperce
    end
  end
end

if defined? ::RSpec            # sometimes we load test-support without loading
  require_relative 'for-rspec' # rspec e.g. to check for warnings or, like,
end                            # visual tests or something
