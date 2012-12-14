require_relative '../core'
require 'skylab/test-support/core'
require 'skylab/headless/core' # only `unstylize`

module Skylab::CovTree::TestSupport
  ::Skylab::TestSupport::Regret[ CovTree_TestSupport = self ]

  module CONSTANTS
    CovTree = ::Skylab::CovTree
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
      @types = []
      @emit_spy = es = ::Skylab::TestSupport::EmitSpy.new
      es.debug = -> { self.debug? }
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

    unstylize = ::Skylab::Headless::CLI::IO::Pen::FUN.unstylize # will change

    define_method :line do
      pair = stack.shift
      if pair
        types.push pair.first
        s = pair.last
        unstylize[ s ] or s
      end
    end

    attr_reader :result

    attr_reader :types

    def stack
      emit_spy.stack
    end
  end
end
