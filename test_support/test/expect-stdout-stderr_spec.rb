require_relative 'test-support'

module Skylab::TestSupport::TestSupport

  # three laws for real

  describe "[ts] expect stdout stderr" do

    it "the module loads" do
      subject
    end

    _Subject = -> do
      Home_::Expect_Stdout_Stderr
    end

    define_method :subject, _Subject

    it "the module has instance methods as part of its public API" do
      subject::Test_Context_Instance_Methods
    end

    context "build some expectation (internal)" do

      me = self
      before :all do
        me.include _Subject[]::Test_Context_Instance_Methods
        me.send :define_method, :expect, me.instance_method( :expect )  # :+#this-rspec-annoyance
      end

      it "build a styled expectation" do
        exp = build_sout_serr_expectation_with :styled
        exp.expect_is_styled.should eql true
      end

      it "build an empty expectation" do
        exp = build_sout_serr_expectation_with
        exp.expect_is_styled.should eql false
      end

      it "build an expectation with CHANNEL STRING" do
        exp = build_sout_serr_expectation_with :err, 'xx'
        exp.stream_symbol.should eql :err
        exp.method_name.should eql :sout_serr_expect_given_string
      end

      it "build an expectation with CHANNEL REGEX" do
        exp = build_sout_serr_expectation_with :out, //
        exp.stream_symbol.should eql :out
        exp.method_name.should eql :sout_serr_expect_given_regex
      end

      def build_sout_serr_expectation_with * x_a, & p
        subject::Expectation.via_args x_a, & p
      end
    end

    context "with an instance that extends the module (me)" do

      me = self
      before :all do
        me.include _Subject[]::Test_Context_Instance_Methods
        me.send :define_method, :expect, me.instance_method( :expect )  # :+#this-rspec-annoyance
      end

      it "when baked emission a is empty - X" do

        against_emissions

        _rx = /\Aexpected an emission, had none\z/
        -> do
          expect :styled, :err, /xxx/
        end.should raise_error ::RuntimeError, _rx
      end

      it "unexpected - X" do

        add_mock_emission :out, "hey\e[32mhi\e[0mhey"
        _rx = %r(\Aexpected no more lines, had \[:out, "he)
        -> do
          expect_no_more_lines
        end.should raise_error _rx
      end

      def add_mock_emission i, s
        @em_a ||= []
        @em_a.push ESS_Mock_Emission.new( i, s )
        nil
      end

      def against_emissions * em_a
        @em_a = em_a
        nil
      end

      def flush_baked_emission_array
        x = @em_a
        @em_a = nil
        x
      end
    end

    context "with spy" do

      it "CHANNEL - does match does match" do
        add_mock_emission :err, nil
        expect :err
        @instance.predicate_spy.should be_nil
        expect_no_more_lines
      end

      it "CHANNEL - does not match does not match" do
        _rx = /\Aexpected\b.+'err'.+\bbut emission was on channel 'out'/
        add_mock_emission :out, nil
        -> do
          expect :err
        end.should raise_error _rx
        expect_no_more_lines
      end

      it "CHANNEL - X (no emission)" do
        _rx = %r(\Aexpected an emission, had none\b)
        -> do
          expect :err
        end.should raise_error _rx
      end

      it "CHANNEL STRING - both matches both matches" do
        add_mock_emission :err, "hi\n"
        expect :err, 'hi'
        expect_no_more_lines
      end

      it "CHANNEL REGEX - both matches both matches" do
        add_mock_emission :out, "hxxxi\n"
        expect :out, /xxx/
        expect_no_more_lines
      end

      it "STRING - does match does match" do
        add_mock_emission nil, "fizzle\n"
        expect 'fizzle'
        @instance.predicate_spy.did_match.should eql true
      end

      it "STRING - does not match does not match" do
        add_mock_emission nil, "torah\n"
        -> do
          expect 'bright'
        end.should raise_error "things were not eql (had torah, #{
          }expected bright)"
      end

      it "REGEX - does match does match" do
        add_mock_emission nil, "Kelly Clark\n"
        expect %r(\bkelly\b)i
        @instance.predicate_spy.did_match.should eql 0
      end

      it "REGEX - does not match does not match" do
        add_mock_emission nil, "Kaitlyn Farrington\n"
        -> do
          expect %r(hannah teeter)
        end.should raise_error "string did not match"
      end

      def add_mock_emission i, x
        instance._baked_em_a.push ESS_Mock_Emission.new( i, x )
        nil
      end

      def expect * a, & p
        instance.expect( * a, & p )
      end

      def instance
        @instance ||= build_instance
      end

      _Mock_Context = nil

      define_method :build_instance do
        _Mock_Context[].new
      end

      _Mock_Context = -> do

        cls = class ESS_Spy_One

          def initialize
            @_baked_em_a = []
          end

          attr_reader :_baked_em_a

          include Home_::Expect_Stdout_Stderr::Test_Context_Instance_Methods

          public :expect, :expect_no_more_lines

          def flush_baked_emission_array
            x = @_baked_em_a
            @_baked_em_a = nil
            x
          end

          def eql x
            @predicate_spy = ESS_Eql_Spy.new x
          end

          def match x
            @predicate_spy = ESS_Match_Spy.new x
          end

          attr_reader :predicate_spy

          self
        end

        _Mock_Context = -> do
          cls
        end

        cls
      end

      def expect_no_more_lines
        instance.expect_no_more_lines
      end
    end

    class ESS_Eql_Spy
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

    class ESS_Match_Spy
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

    ESS_Mock_Emission = ::Struct.new :stream_symbol, :string

  end
end
