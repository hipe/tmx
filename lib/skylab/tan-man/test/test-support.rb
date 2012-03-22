require 'skylab/test-support/test-support'
require 'skylab/test-support/tmpdir'
require 'shellwords'

module Skylab::TanMan::TestSupport
  TanMan = Skylab::TanMan
  include Skylab::TestSupport
  TMPDIR = Tmpdir.new(Skylab::ROOT.join('tmp/tanman'))
  attr_accessor :debug
  def debug!
    tap { |o| o.debug = true }
  end
  def input str
    argv = Shellwords.split(str)
    cli.program_name = 'ferp'
    self.result = cli.invoke argv
  end
  def output
    _output.map(&:to_s)
  end
  attr_accessor :result


  class OutstreamSpy < Struct.new(:stack, :debug)
    def initialize stack, debug
      super
      @yep = false
    end
    def puts o
      if @yep
        stack.last.message.concat(o)
      else
        stack.puts o
      end
    end
    def write s
      @yep = true
      stack.push s
    end
  end
end

RSpec::Matchers.define(:be_trueish) { match { |actual| actual } }

RSpec::Matchers.define(:be_gte) { |expected| match { |actual| actual >= expected } }

