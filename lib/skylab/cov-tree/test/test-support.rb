require_relative '../core'
require 'skylab/test-support/core'
require 'skylab/headless/core' # only `unstylize`

module Skylab::CovTree::TestSupport
  ::Skylab::TestSupport::Regret[ CovTree_TestSupport = self ]

  module CONSTANTS
    CovTree = ::Skylab::CovTree
    TestSupport = ::Skylab::TestSupport
  end

  module InstanceMethods
    extend ::Skylab::MetaHell::Let

    include CONSTANTS # access CovTree from within i.m's in the specs

    def args *args
      debug? and debug "args : #{ args.inspect }"
      c = client
      @result = c.invoke args
      debug? and debug "RESULT: #{ @result.inspect }"
      nil
    end

    def ___build_emit_spy!
      @emit_spy = es = TestSupport::EmitSpy.new
      es.debug = -> { self.debug? }
      @names = []
      es
    end

    def cd path, &block
      CovTree::Headless::CLI::PathTools.clear
      CovTree::Services::FileUtils.cd path, verbose: debug?, &block
    end

    let :client do
      es = ___build_emit_spy!
      CovTree::CLI.new do |rt|
        rt.invocation_slug = 'cov-tree' # this took me 20 minutes to figure out
        rt.on_all do |e|
          es.emit e.type, e.payload
        end
      end
    end

    def debug msg
      $stderr.puts msg
    end

    attr_accessor :do_debug
    alias_method :debug?, :do_debug
    alias_method :debug=, :do_debug=

    def debug!
      self.do_debug = true
    end

    attr_reader :emit_spy

    unstylize = ::Skylab::Headless::CLI::Pen::FUN.unstylize # will change

    define_method :line do
      e = emitted.shift
      if e
        names.push e.name
        unstylize[ e.string ] or e.string
      end
    end

    attr_reader :result

    attr_reader :names

    def emitted
      emit_spy.emitted
    end
  end
end
