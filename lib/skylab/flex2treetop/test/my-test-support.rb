require_relative '../core'
require_relative '../..' # skylab
require 'skylab/test-support/core'

module Skylab::Flex2Treetop::MyTestSupport
  Flex2Treetop = ::Skylab::Flex2Treetop
  StreamSpy = ::Skylab::TestSupport::StreamSpy

  Flex2Treetop.respond_to?(:dir) or begin # for now, futureproofing
    def Flex2Treetop.dir
      @dir ||= ::Skylab::ROOT.join('lib/skylab/css-convert')
    end
  end
  module Headless end
  module Headless::ModuleMethods
    def fixture name
      ::Skylab::ROOT.join(Flex2Treetop::FIXTURES[name]).to_s
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
    include ::Skylab::Headless::CLI::IO::Pen::InstanceMethods # unstylize
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
        o = Flex2Treetop::CLI.new
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
        o = cli_client.send(:build_io_adapter)
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
    alias_method :pen_unstylize, :unstylize
    def unstylize str
      result = pen_unstylize(str)
      result.should_not be_nil
      result
    end
  end
  module API::InstanceMethods
    include Headless::InstanceMethods
    def api_client
      @api_client ||= begin
        o = Flex2Treetop::API::Client.new
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
