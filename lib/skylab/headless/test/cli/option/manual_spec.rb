require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Option::Manual

  ::Skylab::Headless::TestSupport::CLI::Option[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Headless }::CLI::Option" do

    context "for now an option will derive things from long opt (..)" do

      define_method :memoized_option, & MetaHell::FUN.memoize[ -> do
        Headless::CLI::Option.new_flyweight
      end ]   # (it's generally bad and wrong to test this way but we are
      # forcing ourself to use the flyweight to see if we can trigger any
      # errors there, for now)

      let :option do
        opt = memoized_option
        opt.replace_with_normal_args(* args )
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

    context "can be build with Option.on(..)" do

      it "+ normative example" do

        touched = nil

        op = Headless::CLI::Option.on( '-a', '--apple <x>' ) { |x| touched = x }

        op.get_args.should eql( [ '-a', '--apple <x>' ] )

        op.block[ :hi ]
        touched.should eql( :hi )

        op.normal_short_string.should eql( '-a' )
        op.normal_long_string.should eql( '--apple <x>' )
      end

      def on *a, &b
        Headless::CLI::Option.on( *a, &b )
      end

      it "+ you can reflect into the description strings" do
        op = on 'hey', '-a', 'neato', '--apple <x>'
        a = op.sexp.children( :desc ).reduce( [] ) do |m, x| m << x.last end
        a.should eql( [ 'hey', 'neato' ] )
      end

      it "+ if it has zero of the thing, it is not normal" do
        op = on 'desc', '--msg'
        op.normal_short_string.should eql( false )
      end

      context "when there is more than one of the thing" do

        let :op do
          on '--one', '--two'
        end

        it "+ it is not normal" do
          op = self.op
          op.normal_long_string.should eql( false )
        end

        it "+ but you can see them all if you are a sexpert" do
          a = op.sexp.children( :long_sexp ).map do |x|
            x.last.values * ''
          end
          a.should eql( [ '--one', '--two' ] )
        end
      end
    end
  end
end
