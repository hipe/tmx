require_relative '../core'
require_relative '../..' # skylab
require 'skylab/test-support/core'

module Skylab::Flex2Treetop::MyTestSupport

  Flex2Treetop = ::Skylab::Flex2Treetop
  IO_Spy = ::Skylab::TestSupport::IO::Spy

  # keep the below lines for #posterity which are mythically
  # believed to be the origin of "Headless"
  module Headless end
  module Headless::ModuleMethods
    def fixture name
      ::Skylab.dir_pathname.join( Flex2Treetop::FIXTURES.fetch( name ) ).to_s
    end
    _tmpdir_p = -> do
      t = ::Skylab::TestSupport::Tmpdir.
        new ::Skylab::Headless::System.defaults.tmpdir_pathname.join 'f2tt'
      _tmpdir_p = -> { t }
      t
    end
    TMPDIR_F = -> { _tmpdir_p.call }
    def tmpdir
      TMPDIR_F.call
    end
  end

  module Headless::InstanceMethods

    def split_io_spy io_spy
      io_spy[ :buffer ].string.split "\n"
    end

    def fixture *a
      self.class.fixture( * a )
    end

    def tmpdir
      self.class.tmpdir
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
        s = unstyle err.last
        s.should eql('use xyzzy -h for help')
      end
    end
  end

  module CLI::InstanceMethods

    include Headless::InstanceMethods

    [ :inspy, :outspy, :errspy ].each do |i|  # was [#005]
      ivar = "@#{ i }"
      define_method i do
        if instance_variable_defined? ivar
          instance_variable_get ivar
        else
          instance_variable_set ivar, IO_Spy.standard
        end
      end
    end

    attr_accessor :do_debug

    alias_method :debug=, :do_debug=

    def debug!
      @do_debug = true
    end

    def err
      frame[:err].call
    end

    def out
      frame[:out].call
    end

    def frame
      @frame ||= build_frame_h
    end

    def build_frame_h
      inspy ; outspy ; errspy
      do_debug and [ @inspy, @outspy, @errspy ].each( & :debug! )
      cli_client = Flex2Treetop::CLI.new @inspy, @outspy, @errspy
      cli_client.program_name = 'xyzzy'
      r = cli_client.invoke argv
      memoize = -> lamb do
        memo = -> {  v = lamb.call ; ( memo = ->{ v } ).call  }
        -> { memo.call }
      end
      { out:    memoize[ -> { split_io_spy @outspy } ],
        err:    memoize[ -> { split_io_spy @errspy } ],
        result: r }
    end

    def unstyle str
      result = ::Skylab::Headless::CLI::Expression::FUN.unstyle[ str ] # full
      result.should_not be_nil
      result
    end
  end

  module API end

  module API::ModuleMethods
    include Headless::ModuleMethods
  end

  module API::InstanceMethods

    include Headless::InstanceMethods

    def api_client
      @api_client ||= build_api_client
    end

    def build_api_client
      Flex2Treetop::API::Client.new nil, nil, IO_Spy.standard
    end

    def info_stream_lines
      @api_client.infostream[ :buffer ].string.split "\n"
    end
  end
end
