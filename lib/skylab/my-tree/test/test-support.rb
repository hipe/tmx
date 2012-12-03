require_relative '../core'

require 'skylab/headless/test/test-support'
require 'skylab/meta-hell/core'
require 'skylab/test-support/core'

module Skylab::MyTree::TestSupport
  extend ::Skylab::TestSupport::Regret[ self ]


  module CONSTANTS
    Headless = ::Skylab::Headless
    MetaHell = ::Skylab::MetaHell
    MyTree = ::Skylab::MyTree
  end

  include CONSTANTS # so we can use them in the spec body


  module InstanceMethods
    include CONSTANTS             # for immediately below, and others

    extend MetaHell::Let

    attr_reader :debug

    def debug!
      @debug = true
    end

    def invoke *argv
      c = MyTree::CLI.new
      c.send :program_name=, 'mt'
      me = self
      c.singleton_class.send :define_method, :build_io_adapter do
        ioa = Headless::TestSupport::IO_Adapter_Spy.new c.build_pen
        ioa.debug = -> { me.debug }
        ioa
      end
      response = c.invoke argv
      @queue = c.send(:io_adapter).stack
      nil
    end

    def line
      o = shift
      if o
        o.string
      end
    end

    attr_reader :queue

    e = ::Struct.new(:type, :string).new       # flyweight danger stupid

    define_method :shift do
      a = @queue.shift
      if a
        a.map(& :class) == [::Symbol, ::String] or fail('unexpected structure')
        e[:type] = a.first
        e[:string] = Headless::CLI::IO::Pen::FUN.unstylize[ a.last ] || a.last
        e
      end
    end
  end
end
