load File.expand_path('../../../../../bin/yacc2treetop', __FILE__)

require_relative('../..')

require 'skylab/test-support/core'
require 'skylab/headless/core' # unstylize

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
        o = ::Struct.new(:debug_f, :err_f, :out_f).new # 'joystick'
        o.debug_f = ->{ outstream.debug!; errstream.debug! }
        collapsed_f = -> do
          oo = ::Struct.new(:err, :out, :result).new
          oo.result = cli.run argv
          oo.out = outstream.string.split("\n")
          oo.err = errstream.string.split("\n")
          (collapsed_f = ->{ oo }).call
        end
        o.err_f = ->{ collapsed_f.call.err }
        o.out_f = ->{ collapsed_f.call.out }
        o
      end
    end
  end
  module CLI::InstanceMethods
    include ::Skylab::Headless::CLI::Pen::InstanceMethods # unstylize

    FIXTURES = ::Pathname.new(File.expand_path('../fixtures', __FILE__))
    INVITE_RE = /\Ayacc2treetop -h for help\z/
    USAGE_RE = /\Ausage: yacc2treetop .*<yaccfile>/

    def debug! ; _frame.debug_f.call end
    def err    ; _frame.err_f.call   end
    def out    ; _frame.out_f.call   end
    def should_see_usage
      err.shift.should match(USAGE_RE)
      err.size.should eql(0)
    end
  end
end
