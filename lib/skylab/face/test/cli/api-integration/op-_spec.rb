require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::API_Integration::OP_

  ::Skylab::Face::TestSupport::CLI::API_Integration[ TS_ = self ]

  include CONSTANTS

  Face = Face

  extend TestSupport::Quickie

  describe "#{ Face }::CLI::API_Integration::OP_" do

    extend TS_

    before :all do

      class Nerk

        Face::API::Params_[ :client, self, :meta_param, :nerk,
          :param, :email, :arity, :one, :desc, "the email",
          :param, :verbose, :arity, :zero_or_more, :argument_arity, :zero,
            :desc, -> y do
              y << 'verbose.'
              y << '(can be specified multiple times.)'
            end,
          :param, :load_path, :single_letter, 'I', :arity, :zero_or_more,
            :argument_arity, :one, :desc, "note autogenned arg string #{
              }(may be specified more than once)",
          :param, :nerculous, :arity, :zero_or_one,
            :desc, "note the autogenned short gets overridden",
          :param, :dry_run, :single_letter, 'n', :arity, :zero_or_one,
            :argument_arity, :zero ]

        define_singleton_method :build_op, &
          CONSTANTS::Curriable_build_.curry[ self::FIELDS_ ]
      end
    end

    it "generated help screen looks good" do
      op = Nerk.build_op( { } )
      op.summarize( @a = [ ] )
      rx %r(\A +-v, --verbose +verbose\.\z)
      rx %r(\A {15,}\(can be speci.+times\.\)\z)
      rx %r(\A +-I, --load-path <path> +note autogenned.+more than once\)\z)
      rx %r(\A {6,}--nerculous <nerculous> +note.+gets overridden\z)
      rx %r(\A +-n, --dry-run\z)  # this is what overrode the autogenned short
    end

    def parse * args
      parse_args args
    end

    def parse_args args
      op = Nerk.build_op( h = { } )
      op.parse! args
      h
    end

    context "with a poly/mono option (arity: 0.., arg arity: 1)" do

      it "provide one arg to multi multi - array" do
         h = parse '--load-path', 'zing'
         h.should eql( load_path: [ 'zing' ] )
      end

      it "provide multi to multi multi - array" do
        h = parse '-Ix', '-I', 'y'
        h.should eql( load_path: %w(x y) )
      end

      it "provide none to same (when switch follows) - swallows" do
        h = parse '-I', '-v'
        h.should eql( load_path: [ '-v' ] )
      end

      it "provide none to same - raises optparse exception" do
        -> do
          parse '-I'
        end.should raise_error(
          ::OptionParser::MissingArgument, /missing argument: -I/ )
      end
    end

    context "with a poly/nil option (arity: 0.., arg arity: 0)" do

      it "multiple flags (normative case) - count" do
        h = parse '-v', '-v', '-v'
        h.should eql( verbose: 3 )
      end

      it "mutliple flags (as -vvv) - count" do
        h = parse '-vvv'
        h.should eql( verbose: 3 )
      end

      it "when arg-like follows" do
        h = parse_args( args = [ '-v', 'zippo' ] )
        h.should eql( verbose: 1 )
        args.should eql( [ 'zippo' ] )
      end
    end

    context "with a mono/mono" do

      it "normaitve case (one arg provided) - ok" do
        h = parse '--nerc', 'zip'
        h.should eql( nerculous: 'zip' )
      end

      it "one arg, with equals - ok" do
        h = parse '--ne=zap'
        h.should eql( nerculous: 'zap' )
      end

      it "with no arg - library exception" do
        -> do
          parse '--ne'
        end.should raise_error(
          ::OptionParser::MissingArgument, /\Amissing argument: --ne\z/ )
      end

      it "with multiple invocations of the parameter - UPGRADES to array" do
        parse( '--ne', 'one', '--ne', 'two' ).
          should eql( nerculous: [ 'one', 'two' ] )
      end
    end

    context "with a mono/nil" do

      it "normative (just the flag) - ok value is true" do
        parse( '-n' ).should eql( dry_run: true )
      end

      it "when an arg-like follows - ok" do
        args = [ '-n', 'zip' ]
        parse_args( args ).should eql( dry_run: true )
        args.should eql( [ 'zip' ] )
      end

      it "multiple - UPGRADES to number" do
        parse( '-nn' ).should eql( dry_run: 2 )
      end
    end

    context "look there's a meta-param"

    context "multiple desc" do
      class Derk
        Face::API::Params_[ :client, self,
          :param, :wiffle, :arity, :zero_or_one, :desc, "one", :desc, "two" ]

        define_singleton_method :build_op, &
          CONSTANTS::Curriable_build_.curry[ self::FIELDS_ ]
      end

      it "what happens? - the second overwrites the first" do
        op = Derk.build_op( { } )
        op.summarize( @a = [ ] )
        rx %r(\A +-w, --wiffle <wiffle> +two\z)
      end
    end
  end
end
