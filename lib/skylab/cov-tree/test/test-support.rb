require_relative '../cli' # for now

require 'skylab/headless/core'
require 'skylab/meta-hell/core'
require 'skylab/test-support/core'

module Skylab::CovTree::TestSupport
  ::Skylab::TestSupport::Regret[ CovTree_TestSupport = self ]

  module CONSTANTS
    CovTree = ::Skylab::CovTree
  end

  module InstanceMethods
    extend ::Skylab::MetaHell::Let

    include CONSTANTS # access CovTree from within i.m's in the specs

    def args *args
      c = client
      @result = c.invoke args
      nil
    end

    let :client do
      @types = []
      @emit_spy = es = ::Skylab::TestSupport::EmitSpy.new
      es.debug = -> { self.debug }
      CovTree::CLI.new do |rt|
        rt.invocation_slug = 'cov-tree' # this took me 20 minutes to figure out
        rt.on_all do |e|
          es.emit e.type, e.payload
        end
      end
    end

    attr_accessor :debug

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
