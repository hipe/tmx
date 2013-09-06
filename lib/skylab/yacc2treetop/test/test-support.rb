load ::File.expand_path( '../../../../../bin/tmx-yacc2treetop', __FILE__ )
require_relative '../..'
require 'skylab/test-support/core'
require 'skylab/headless/core' # unstyle

module Skylab::Yacc2Treetop::TestSupport
  Yacc2Treetop = ::Skylab::Yacc2Treetop
  module CLI
    def self.extended mod
      mod.module_eval do
        extend CLI::ModuleMethods
        include CLI::InstanceMethods
      end
    end
  end
  module CLI::ModuleMethods
    def invoke *argv
      let(:_frame) do
        errstream = ::Skylab::TestSupport::IO::Spy.standard
        outstream = ::Skylab::TestSupport::IO::Spy.standard
        cli = Yacc2Treetop::CLI.new(outstream, errstream)
        cli.program_name = 'yacc2treetop'
        o = ::Struct.new(:debug_p, :err_p, :out_p).new # 'joystick'
        o.debug_p = ->{ outstream.debug!; errstream.debug! }
        collapsed_p = -> do
          oo = ::Struct.new(:err, :out, :result).new
          oo.result = cli.run argv
          oo.out = outstream.string.split("\n")
          oo.err = errstream.string.split("\n")
          (collapsed_p = ->{ oo }).call
        end
        o.err_p = ->{ collapsed_p.call.err }
        o.out_p = ->{ collapsed_p.call.out }
        o
      end
    end
  end

  module CLI::InstanceMethods

    FIXTURES = ::Pathname.new(File.expand_path('../fixtures', __FILE__))
    INVITE_RX = /\Ayacc2treetop -h for help\z/
    USAGE_RX = /\Ausage: yacc2treetop .*<yaccfile>/

    def debug! ; _frame.debug_p.call end
    def err    ; _frame.err_p.call   end
    def out    ; _frame.out_p.call   end
    def should_see_usage
      err.shift.should match(USAGE_RX)
      err.size.should eql(0)
    end

    define_method :unstyle, & ::Skylab::Headless::CLI::Pen::FUN.unstyle
  end
end
