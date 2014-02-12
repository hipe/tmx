require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Client::API_Integration::Par

  ::Skylab::Face::TestSupport::CLI::Client::API_Integration[ self, :CLI_party]

  describe "[fa] CLI client API integration - the `par` method" do

    extend TS__

    context "on an option" do

      before :all do

        class Minsky < Base_Magic_

          Face_::API::Params_[ :client, self,
            :param, :favorite_email, :arity, :one,
            :param, :secondary_email, :arity, :zero_or_one ]

          define_singleton_method :build_op, &
            CONSTANTS::Curriable_build_.curry[ field_box ]

          def execute
            "f:#{ Shorten_email[ @favorite_email ] },s:#{
              }#{ Shorten_email[ @secondary_email ] || '(none)' }"
          end
        end
      end

      it "the op looks ok - two params but only one option" do
        op = Minsky::build_op( { } )
        op.summarize( @a = [ ] )
        rx %r{ \A [ ]+ -s, [ ] --secondary-email [ ] <email> \z }x
        expect_no_more_lines
      end

      it "use an option correctly - ok" do
        ag = Minsky.new infostream
        op = ag.build_op
        op.parse '--secondary-email', 'foom@boom'
        ag.param_h.keys.should eql( [ :secondary_email ] )
        ag.param_h.values.should eql( [ 'foom@boom' ] )
        ag.param_h[ :favorite_email ] = 'wenker@denker'
        r = ag.flush
        r.should eql( 'f:w@d,s:f@b' )
      end

      it "invoke a monadic option multiple times - stylized parameter" do
        ag = Minsky.new infostream
        op = ag.build_op
        argv = [ '--secondary-email', 'foo@x', '-s', 'a@b' ]
        op.parse! argv
        argv.length.should be_zero
        ag.param_h[ :favorite_email ] = 'x@x'
        r = ag.flush
        r.should eql( false )
        raw = expect_styled only_line
        raw.should match( /multiple arguments were provided for #{
          }--secondary-email but only one can be accepted/i )
      end
    end

    context "on an argument (an integration test)" do

      before :all do
        class Pinsky < Base_Magic_
          Face_::API::Params_[ :client, self,
            :param, :primary_email, :arity, :one, :normalizer, -> y, x, p do
              if /[0-9]/ =~ x
                say do
                  y << "#{ par :primary_email } cannot contain digits #{
                    }(it's part of the standard)"
                  y << "(use #{ par :force } to override this)"
                  nil
                end
                false
              else
                p[ x.upcase ]
                true
              end
            end,
            :param, :force, :arity, :zero_or_one, :argument_arity, :zero
          ]
          def execute
            Shorten_email[ @primary_email ]
          end

          o = Face_::API::Normalizer_

          define_method :say, o::Build_say_method_[ -> do
            @front_expression_agent ||= o::Field_Front_Exp_Ag_.
              new field_box, some_expression_agent
          end ]
        end
      end

      it "takes the good argument" do
        ag = Pinsky.new infostream
        ag.param_h[ :primary_email ] = "wenkers@dankers"
        ag.init_expression_agent_for_cli
        r = ag.flush
        r.should eql( 'W@D' )
      end

      it "with a an invalid value .." do
        ag = Pinsky.new infostream
        ag.param_h[ :primary_email ] = 'abc123@foo'
        ag.init_expression_agent_for_cli
        r = ag.flush
        r.should eql( false )
        expect_styled( line ).should match( /\A<primary-email> cannot contain digit/ )
        expect_styled( only_line ).should match( /\A\(use --force to ov/ )
      end
    end

    class Base_Magic_

      Face_::API::Normalizer_.enhance_client_class self, :all

      def self.field_box
        self::FIELDS_
      end

      def initialize infostream
        @infostream = infostream
        @param_h = { }
      end

      attr_reader :param_h

      def build_op
        init_expression_agent_for_cli
        CONSTANTS::Curriable_build_[ field_box, @param_h ]
      end

      def init_expression_agent_for_cli  # eew
        @expression_agent ||= CONSTANTS::CLI_expression_agent_[]
        nil
      end

    private

      def field_box
        self.class.field_box
      end

      def any_expression_agent
        @expression_agent
      end

      def some_expression_agent
        @expression_agent or fail "sanity - exp ag ?"
      end
    end

    Shorten_email = -> s do
      s and %r{\A(.)[^@]*@(.)}.match( s ).captures * '@'
    end
  end
end
