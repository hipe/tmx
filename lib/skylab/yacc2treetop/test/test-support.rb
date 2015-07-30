load ::File.expand_path( '../../../../../bin/tmx-yacc2treetop', __FILE__ )
require_relative '../..'
require 'skylab/test-support/core'

Skylab::TestSupport::Quickie.enable_kernel_describe

module Skylab::Yacc2Treetop::TestSupport

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

        errstream = ::Skylab::TestSupport::IO.spy.new
        outstream = ::Skylab::TestSupport::IO.spy.new

        cli = Home_::CLI.new :_no_sin_, outstream, errstream, [ 'yacc2treetop' ]

        o = ::Struct.new(:debug_p, :err_p, :out_p).new  # :+[#hl-078] "shell"
        o.debug_p = ->{ outstream.debug!; errstream.debug! }
        collapsed_p = -> do
          oo = ::Struct.new(:err, :out, :result).new
          oo.result = cli.invoke argv
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

    define_method :unstyle, -> do
      p = -> s do
        require 'skylab/brazen/core'
        p = ::Skylab::Brazen::CLI::Styling::Unstyle_styled
        p[ s ]
      end
      -> s do
        p[ s ]
      end
    end.call
  end

  Home_ = ::Skylab::Yacc2Treetop

end
