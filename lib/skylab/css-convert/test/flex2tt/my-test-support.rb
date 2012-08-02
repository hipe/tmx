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

  FlexToTreetop.respond_to?(:dir) or begin # for now, futureproofing
    def FlexToTreetop.dir
      @dir ||= ::Skylab::ROOT.join('lib/skylab/css-convert')
    end
  end
  module Headless end
  module Headless::ModuleMethods
    def fixture name
      ::Skylab::ROOT.join(FlexToTreetop::FIXTURES[name]).to_s
    end
    _tmpdir_f = -> do
      t = ::Skylab::TestSupport::Tmpdir.new(::Skylab::ROOT.join('tmp/f2tt'))
      (_tmpdir_f = ->{t}).call
    end
    TMPDIR_F = -> { _tmpdir_f.call }
    def tmpdir
      TMPDIR_F.call
    end
  end
  module CLI end
  module CLI::ModuleMethods
    include Headless::ModuleMethods
    def argv *argv
      let(:argv) { argv }
    end
    def an_explanation msg, exp, *a
      it "shows an explanation #{msg}", *a do
        err.first.should match(exp)
      end
    end
    def an_invite *a
      it "shows an invite line" do
        err.last.should eql("use \e[1;32mxyzzy -h\e[0m for more help")
      end
    end
  end
  module API end
  module API::ModuleMethods
    include Headless::ModuleMethods
  end
  module Headless::InstanceMethods
    def fixture(*a) ; self.class.fixture(*a) end
    def _split name
      io_adapter_spy.send(name)[:buffer].string.split("\n")
    end
    def tmpdir
      self.class.tmpdir
    end
  end
  module CLI::InstanceMethods
    include Headless::InstanceMethods
    [:inspy, :outspy, :errspy].each do |sym|
      ivar = "@#{sym}"
      define_method(sym) do
        instance_variable_defined?(ivar) ? instance_variable_get(ivar) :
          instance_variable_set(ivar, StreamSpy.standard)
      end
    end
    def cli_client
      @cli_client ||= begin
        o = FlexToTreetop::CLI.new
        o.send(:program_name=, 'xyzzy')
        o
      end
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
        err: memoize[->{ _split(:errstream) }],
        out: memoize[->{ _split(:outstream) }],
        result: result
      }
    end
    def io_adapter_spy
      @spy ||= begin
        o = cli_client.build_io_adapter
        o.instream = inspy ; o.outstream = outspy ; o.errstream = errspy
        def o.debug!
          instream.debug! ; outstream.debug! ; errstream.debug!
          self
        end
        o
      end
    end
    def out
      frame[:out].call
    end
  end
  module API::InstanceMethods
    include Headless::InstanceMethods
    def api_client
      @api_client ||= begin
        o = FlexToTreetop::API::Client.new
        o.request_runtime.io_adapter.info_stream = StreamSpy.standard
        o
      end
    end
    def info_stream_lines
      api_client.request_runtime.io_adapter.
        info_stream[:buffer].string.split("\n")
    end
  end
end
