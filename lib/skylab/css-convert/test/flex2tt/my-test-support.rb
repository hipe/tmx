# we don't use the test-support from the rest of the sub-module because
# we need to ensure that this library can function indepedantly of the
# rest of it.  hence the "my-" to avoid confusion and highlight this.

unless defined? ::Skylab::Flex2Treetop
  load File.expand_path('../../../../../../bin/flex2treetop', __FILE__)
end

require_relative '../../..'
require 'skylab/test-support/core'

module Skylab::FlexToTreetop::MyTestSupport
  FlexToTreetop = ::Skylab::FlexToTreetop
  StreamSpy = ::Skylab::TestSupport::StreamSpy
  module ModuleMethods
    def argv *argv
      [:inspy, :outspy, :errspy].each do |sym|
        let(sym) { StreamSpy.standard }
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
        _bad = listing.select { |s| s !~ /\A[[:space:]]+/ }
        _bad.length.should eql(0)
      end
    end
  end
  module InstanceMethods
    def api_client
      @api_client ||= begin
        o = FlexToTreetop::API::Client.new
        o.request_runtime.io_adapter.info_stream = StreamSpy.standard
        o
      end
    end
    def cli_client
      @cli_client ||= FlexToTreetop::CLI.new
    end
    def err
      frame[:err].call
    end
    def frame
      @frame ||= nil and return @frame
      cli_client.request_runtime.io_adapter = io_adapter_spy
      argv = self.argv # can be erased
      result = cli_client.invoke(argv)
      memoize = ->(lamb) do
        memo = -> { v = lamb.call ; (memo = ->{ v }).call }
        -> { memo.call }
      end
      @frame = {
        err: memoize[->{ _split(:errput) }],
        out: memoize[->{ _split(:output) }],
        result: result
      }
    end
    def out
      frame[:out].call
    end
    def io_adapter_spy
      @spy ||= begin
        o = FlexToTreetop::CLI::IO::Adapter.new(inspy, outspy, errspy)
        def o.debug!
          input.debug! ; output.debug! ; errput.debug!
          self
        end
        o
      end
    end
    def _split name
      io_adapter_spy.send(name)[:buffer].string.split("\n")
    end
  end
end
