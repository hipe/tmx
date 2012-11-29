require_relative '../core'
require_relative '../..' # skylab
require 'skylab/test-support/core'

module Skylab::Flex2Treetop::MyTestSupport
  Flex2Treetop = ::Skylab::Flex2Treetop
  StreamSpy = ::Skylab::TestSupport::StreamSpy

  # for posterity, we have to keep the below lines, which are mythically
  # believed to be the origin of "Headless"
  module Headless end
  module Headless::ModuleMethods
    def fixture name
      ::Skylab.dir_pathname.join( Flex2Treetop::FIXTURES.fetch( name ) ).to_s
    end
    _tmpdir_f = -> do
      t = ::Skylab::TestSupport::Tmpdir.new(
        ::Skylab::TMPDIR_PATHNAME.join('f2tt')
      )
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
        s = unstylize err.last
        s.should eql('use xyzzy -h for help')
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
    [:inspy, :outspy, :errspy].each do |sym|  # so awful, away at [#005]
      ivar = "@#{sym}"
      define_method sym do
        if instance_variable_defined? ivar
          instance_variable_get ivar
        else
          o = StreamSpy.standard
          instance_variable_set ivar, o
        end
      end
    end
    def cli_client
      @cli_client ||= begin
        o = Flex2Treetop::CLI.new
        o.send :program_name=, 'xyzzy'
        o
      end
    end
    attr_accessor :do_debug
    alias_method :debug=, :do_debug=
    def err
      frame[:err].call
    end
    def frame
      @frame ||= nil and return @frame
      ioa = io_adapter_spy
      do_debug and ioa.debug!
      cli_client.send :io_adapter=, ioa
      result = cli_client.invoke argv
      memoize = -> lamb do
        memo = -> {  v = lamb.call ; ( memo = ->{ v } ).call  }
        -> { memo.call }
      end
      @frame = {
        err: memoize[->{ _split(:errstream) }],
        out: memoize[->{ _split(:outstream) }],
        result: result
      }
    end
    def io_adapter_spy #  away at [#005]
      @spy ||= begin
        o = cli_client.send :build_io_adapter
        o.instream = inspy
        o.outstream = outspy
        o.errstream = errspy
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
    def unstylize str
      result = ::Skylab::Headless::CLI::IO::Pen::FUN.unstylize[ str ] # full
      result.should_not be_nil
      result
    end
  end
  module API::InstanceMethods
    include Headless::InstanceMethods
    def api_client
      @api_client ||= begin
        o = Flex2Treetop::API::Client.new
        o.send(:io_adapter).info_stream = StreamSpy.standard
        o
      end
    end
    def info_stream_lines
      api_client.send(:io_adapter).info_stream[:buffer].string.split "\n"
    end
  end
end
