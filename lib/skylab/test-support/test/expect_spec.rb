require_relative 'test-support'

module Skylab::TestSupport::TestSupport::Expect_

  TestSupport_ = ::Skylab::TestSupport
  TestSupport_::TestSupport[ self ]
  extend TestSupport_::Quickie
  include TestSupport_  # constants like 'EMPTY_A_'

  # three laws for real

  describe "[ts] expect" do

    it "the module loads" do
      TestSupport_::Expect
    end

    it "the module has instance methods" do
      TestSupport_::Expect::InstanceMethods
    end

    context "build some expectatsion (internal)" do

      me = self
      before :all do
        me.include TestSupport_::Expect::InstanceMethods
      end

      it "build a styled expectation" do
        exp = build_expectation :styled
        exp.expect_is_styled.should eql true
      end

      it "build an empty expectation" do
        exp = build_expectation
        exp.expect_is_styled.should eql false
      end

      it "build an expectation with CHANNEL STRING" do
        exp = build_expectation :err, 'xx'
        exp.channel_i.should eql :err
        exp.pattern_method.should eql :match_with_string
      end

      it "build an expectation with CHANNEL REGEX" do
        exp = build_expectation :out, //
        exp.channel_i.should eql :out
        exp.pattern_method.should eql :match_with_regex
      end
    end

    context "with an instance that extends the module" do

      before :all do
        class Spy_One
          def initialize
            @_baked_em_a = []
          end
          include TestSupport_::Expect::InstanceMethods
          public :expect
          attr_reader :_baked_em_a
          def build_baked_em_a
            r = @_baked_em_a ; @_baked_em_a = nil ; r
          end
          def eql x
            @predicate_spy = Eql_Spy_.new x
          end
          def match x
            @predicate_spy = Match_Spy_.new x
          end
          attr_reader :predicate_spy
        end
      end ; def cls ; Spy_One end

      it "when baked emission a is empty - X" do
        -> do
          expect :styled, :err, /xxx/
        end.should raise_error ::RuntimeError, /\Aexpected an emission #{
          }on the 'err' channel\z/
      end

      it "unexpected - X" do
        add_mock_emission :out, "hey\e[32mhi\e[0mhey"
        -> do
          expect_no_more_emissions
        end.should raise_error %r(\Aunexpected 'out' emission: #{
          }"hey..\[32mhi..\[0mhey"\z)
      end

      it "CHANNEL - does match does match" do
        add_mock_emission :err, nil
        expect :err
        @instance.predicate_spy.did_match.should eql true
        expect_no_more_emissions
      end

      it "CHANNEL - does not match does not match" do
        add_mock_emission :out, nil
        -> do
          expect :err
        end.should raise_error "things were not eql (had out, expected err)"
        expect_no_more_emissions
      end

      it "CHANNEL - X (no emission)" do
        -> do
          expect :err
        end.should raise_error %r(\Aexpected an emission on the 'err' #{
          }channel\z)
      end

      it "CHANNEL STRING - both matches both matches" do
        add_mock_emission :err, 'hi'
        expect :err, 'hi'
        expect_no_more_emissions
      end

      it "CHANNEL REGEX - both matches both matches" do
        add_mock_emission :out, 'hxxxi'
        expect :out, /xxx/
        expect_no_more_emissions
      end

      it "STRING - does match does match" do
        add_mock_emission nil, 'fizzle'
        expect 'fizzle'
        @instance.predicate_spy.did_match.should eql true
      end

      it "STRING - does not match does not match" do
        add_mock_emission nil, 'torah'
        -> do
          expect 'bright'
        end.should raise_error "things were not eql (had torah, #{
          }expected bright)"
      end

      it "REGEX - does match does match" do
        add_mock_emission nil, 'Kelly Clark'
        expect %r(\bkelly\b)i
        @instance.predicate_spy.did_match.should eql 0
      end

      it "REGEX - does not match does not match" do
        add_mock_emission nil, 'Kaitlyn Farrington'
        -> do
          expect %r(hannah teeter)
        end.should raise_error "string did not match"
      end

      it "BLOCK"

      def add_mock_emission i, s
        instance._baked_em_a << Mock_Emission_.new( i, s ) ; nil
      end

      def expect * a, & p
        instance.expect( * a, & p )
      end

      def expect_no_more_emissions
        instance.expect_no_more_emissions
      end
    end

    it "compound emission channels"

    class Mock_Emission_
      def initialize i, s
        @channel_i = i ; @payload_x = s ; nil
      end
      attr_reader :channel_i, :payload_x
    end

    def build_expectation * a, & p
      build_expectation_from_x_a_and_p a, p
    end

    def instance
      @instance ||= build_instance
    end

    def build_instance
      cls.new
    end

    class Eql_Spy_
      def initialize x
        @expected = x
      end
      attr_reader :did_match
      def match x
        @did_match = @expected == x
        @did_match or raise "things were not eql #{
          }(had #{ x }, expected #{ @expected })"
      end
      alias_method :matches?, :match
    end

    class Match_Spy_
      def initialize x
        @expected = x
      end
      attr_reader :did_match
      def match x
        @did_match = @expected =~ x
        @did_match or raise "string did not match"
      end
      alias_method :matches?, :match
    end
  end
end
