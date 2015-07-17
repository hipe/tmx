require_relative '../test-support'

module Skylab::Bnf2Treetop::TestSupport

  Home_ = ::Skylab::Bnf2Treetop
  Callback_ = ::Skylab::Callback
  TestSupport_ = ::Skylab::TestSupport

  module TestLib_

    sidesys = Callback_::Autoloader.build_require_sidesystem_proc

    CLI_lib = -> do
      HL__[]::CLI
    end

    Brazen = sidesys[ :Brazen ]

    HL__ = sidesys[ :Headless ]

  end

  module CLI
    def self.extended mod
      mod.module_eval do
        extend CLI::ModuleMethods
        include CLI::InstanceMethods
      end
    end
  end

  module CLI::ModuleMethods

    MOCK_INTERACTIVE_STDIN___ = -> do
      o = ::Module.new
      Mock_Interactive_STDIN___ =  o
      def o.tty?
        false
      end
      o
    end.call

    def invoke *argv, &output_p

      ::Hash === argv.last and tags = argv.pop # BE CAREFUL!!!!

      let :_frame do

        errstream = TestSupport_::IO.spy.new
        outstream = TestSupport_::IO.spy.new

        cli = Home_::CLI.new(
          MOCK_INTERACTIVE_STDIN___,
          outstream,
          errstream,
          '/no-see/bnf2treetop'
        )

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

      if output_p
        make_an_example_out_of output_p, * tags
      end
    end

    def make_an_example_out_of output_p, *a
      o = ::BasicObject.new
      labels = []
      sc = class << o ; self end # ::BasicObject has no define_singleton_method
      sc.send :define_method,  :method_missing do |m, *aa|
        if aa.length.nonzero?
          labels.push "#{ m.to_s.gsub '_', ' ' }#{ '(..)' }"
        end
      end
      o.instance_eval(&output_p)
      labels.empty? and labels.push('(none)') # sanity
      it "outputs #{labels.join(', ')}", *a do
        instance_eval(&output_p)
      end
    end
  end

  module CLI::InstanceMethods

    FIXTURES = ::Pathname.new(File.expand_path('../../fixtures', __FILE__))

    def debug! ; _frame.debug_p.call end
    def err    ; _frame.err_p.call   end
    def out    ; _frame.out_p.call   end

    def unstyle x
      TestLib_::Brazen[]::CLI::Styling.unstyle x
    end
  end
end
