module Skylab::BNF2Treetop::TestSupport

  module CLI

    def self.[] tcc
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
    end
  end

  module CLI::Module_Methods___

    def invoke *argv, &output_p

      ::Hash === argv.last and tags = argv.pop # BE CAREFUL!!!!

      let :_frame do

        errstream = TestSupport_::IO.spy.new
        outstream = TestSupport_::IO.spy.new

        _stdin = CLI::TestLib__::System_lib[].test_support::
          STUBS.noninteractive_STDIN_instance

        cli = Home_::CLI.new(
          argv,
          _stdin,
          outstream,
          errstream,
          [ '/no-see/bnf2treetop' ]
        )

        o = ::Struct.new(:debug_p, :err_p, :out_p).new  # :+[#bs-037] "shell"

        o.debug_p = ->{ outstream.debug!; errstream.debug! }

        collapsed_p = -> do
          oo = ::Struct.new(:err, :out, :result).new
          oo.result = cli.execute
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
          labels.push "#{ m.to_s.gsub UNDERSCORE_, SPACE_ }#{ '(..)' }"
        end
      end
      o.instance_eval(&output_p)
      labels.empty? and labels.push('(none)') # sanity
      it "outputs #{labels.join(', ')}", *a do
        instance_eval(&output_p)
      end
    end
  end

  module CLI::Instance_Methods___

    FIXTURES = ::File.join Home_.sidesystem_path, 'test/fixture-files'

    def debug! ; _frame.debug_p.call end
    def err    ; _frame.err_p.call   end
    def out    ; _frame.out_p.call   end

    def unstyle x
      CLI::TestLib__::Zerk[]::CLI::Styling.unstyle x
    end
  end

  module CLI::TestLib__

    sidesys = Common_::Autoloader.build_require_sidesystem_proc

    Brazen = sidesys[ :Brazen ]

    System_lib = sidesys[ :System ]

    Zerk = sidesys[ :Zerk ]

  end
end
