require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Option
  ::Skylab::Headless::TestSupport::CLI[ Option_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Headless }::CLI::Option" do

    context "for now an option will derive things form long opt (..)" do

      define_method :memoized_option, & MetaHell::FUN.memoize[ -> do
        Headless::CLI::Option.new_flyweight
      end ]   # (it's generally bad and wrong to test this way but we are
      # forcing ourself to use the flyweight to see if we can trigger any
      # errors there, for now)

      let :option do
        opt = memoized_option
        opt.replace_with_args(* args )
        opt
      end

      -> do
        args = [ '-x', '--ed-banger <num>' ]
        let :args do args end

        fmt = "%-16s - %15s => %s"

        -> do
          exp = :ed_banger
          it "#{ fmt % [ '`norm.name`', args.inspect, exp.inspect ] }" do
            option.normalized_parameter_name.should eql( exp )
          end
        end.call

        -> do
          exp = "--ed-banger"
          it "#{ fmt % [ '`as_parameter_signifier`', args.inspect, exp.inspect ] }" do
            option.as_parameter_signifier.should eql( exp )
          end
        end.call
      end.call
    end
  end
end
