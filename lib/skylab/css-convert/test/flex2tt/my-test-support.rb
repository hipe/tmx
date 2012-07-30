# we don't use the test-support from the rest of the sub-module because
# we need to ensure that this library can function indepedantly of the
# rest of it.  hence the "my-" to avoid confusion and highlight this.

unless defined? ::Skylab::Flex2Treetop
  load File.expand_path('../../../../../../bin/flex2treetop', __FILE__)
end

require_relative '../../..'
require 'skylab/test-support/core'

module Skylab::FlexToTreetop::MyTestSupport
  module ModuleMethods
    def argv *argv
      [:inspy, :outspy, :errspy].each do |sym|
        let(sym) { ::Skylab::TestSupport::StreamSpy.standard }
      end
      let(:argv) { argv }
    end
    def an_explanation msg, exp, *a
      it "shows an explanation #{msg}", *a do
        err.first.should match(exp)
      end
    end
    def more_help *a
      it "shows more help", *a do
        err[1].should match(/usage: rspec \[options\] <flexfile>/i) # etc
        listing = err[2..-1]
        listing.length.should be > 0
        _bad = listing.select { |s| s !~ /\A[[:space:]]+-/ }
        _bad.length.should eql(0)
      end
    end
  end
  module InstanceMethods
    include ::Skylab::FlexToTreetop
    def client
      @client ||= ::Skylab::FlexToTreetop.cli
    end
    def err
      frame[:err].call
    end
    def frame
      @frame ||= nil and return @frame
      _rt = request_runtime_spy
      client.singleton_class.send(:define_method, :build_execution_context) do
        _rt
      end
      argv = self.argv # can be erased
      result = client.run(argv)
      memoize = ->(lamb) do
        memo = -> { v = lamb.call ; (memo = ->{ v }).call }
        -> { memo.call }
      end
      @frame = {
        err: memoize[->{ _split(:err) }],
        out: memoize[->{ _split(:out) }],
        result: result
      }
    end
    def out
      frame[:out].call
    end
    def request_runtime_spy
      @spy ||= begin
        o = client.build_execution_context
        o.in = inspy ; o.out = outspy ; o.err = errspy
        def o.debug! ; %w(in out err).each { |x| send(x).debug! } ; self end
        o
      end
    end
    def _split name
      request_runtime_spy.send(name)[:buffer].string.split("\n")
    end
  end
end
