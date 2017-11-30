require_relative 'test-support'

module Skylab::TestSupport::TestSupport

  # three laws for real

  describe "[ts] want stdout stderr" do

    it "the module loads" do
      subject
    end

    _Subject = -> do
      Home_::Want_Stdout_Stderr
    end

    define_method :subject, _Subject

    it "the module has instance methods as part of its public API" do
      subject::Test_Context_Instance_Methods
    end

    context "build some expectation (internal)" do

      me = self
      before :all do
        me.include _Subject[]::Test_Context_Instance_Methods
      end

      it "build a styled expectation" do
        exp = build_sout_serr_expectation_with :styled
        expect( exp.want_is_styled ).to eql true
      end

      it "build an empty expectation" do
        exp = build_sout_serr_expectation_with
        expect( exp.want_is_styled ).to eql false
      end

      it "build an expectation with CHANNEL STRING" do
        exp = build_sout_serr_expectation_with :err, 'xx'
        expect( exp.stream_symbol ).to eql :err
        expect( exp.method_name ).to eql :sout_serr_want_given_string
      end

      it "build an expectation with CHANNEL REGEX" do
        exp = build_sout_serr_expectation_with :out, //
        expect( exp.stream_symbol ).to eql :out
        expect( exp.method_name ).to eql :sout_serr_want_given_regex
      end

      def build_sout_serr_expectation_with * x_a, & p
        subject::Expectation.via_args x_a, & p
      end
    end

    context "with an instance that extends the module (me)" do

      me = self
      before :all do
        me.include _Subject[]::Test_Context_Instance_Methods
      end

      it "when baked emission a is empty - X" do

        against_emissions

        _rx = /\Aexpected an emission, had none\z/
        expect( -> do
          want :styled, :err, /xxx/
        end ).to raise_error ::RuntimeError, _rx
      end

      it "unexpected - X" do

        add_mock_emission :out, "hey\e[32mhi\e[0mhey"
        _rx = %r(\Aexpected no more lines, had \[:out, "he)
        expect( -> do
          want_no_more_lines
        end ).to raise_error _rx
      end

      def add_mock_emission i, s
        @em_a ||= []
        @em_a.push X_wss_Mock_Emission.new( i, s )
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
        want :err
        expect( @instance.predicate_spy ).to be_nil
        want_no_more_lines
      end

      it "CHANNEL - does not match does not match" do
        _rx = /\Aexpected\b.+'err'.+\bbut emission was on channel 'out'/
        add_mock_emission :out, nil
        expect( -> do
          want :err
        end ).to raise_error _rx
        want_no_more_lines
      end

      it "CHANNEL - X (no emission)" do
        _rx = %r(\Aexpected an emission, had none\b)
        expect( -> do
          want :err
        end ).to raise_error _rx
      end

      it "CHANNEL STRING - both matches both matches" do
        add_mock_emission :err, "hi\n"
        want :err, 'hi'
        want_no_more_lines
      end

      it "CHANNEL REGEX - both matches both matches" do
        add_mock_emission :out, "hxxxi\n"
        want :out, /xxx/
        want_no_more_lines
      end

      it "STRING - does match does match" do
        add_mock_emission nil, "fizzle\n"
        want 'fizzle'
        expect( @instance.predicate_spy.did_match ).to eql true
      end

      it "STRING - does not match does not match" do
        add_mock_emission nil, "torah\n"
        expect( -> do
          want 'bright'
        end ).to raise_error "things were not eql (had torah, #{
          }expected bright)"
      end

      it "REGEX - does match does match" do
        add_mock_emission nil, "Kelly Clark\n"
        want %r(\bkelly\b)i
        expect( @instance.predicate_spy.did_match ).to eql 0
      end

      it "REGEX - does not match does not match" do
        add_mock_emission nil, "Kaitlyn Farrington\n"
        expect( -> do
          want %r(hannah teeter)
        end ).to raise_error "string did not match"
      end

      def add_mock_emission i, x
        _em = X_wss_Mock_Emission.new i, x
        instance.__add_emission_ _em
        nil
      end

      def want * a, & p
        instance.want( * a, & p )
      end

      def instance
        @instance ||= build_instance
      end

      _Mock_Context = nil

      define_method :build_instance do
        _Mock_Context[].new
      end

      _Mock_Context = -> do

        cls = class X_wss_Spy_One

          def initialize
            @__this_one_mutex = nil
            @_baked_em_a = []
          end

          include Home_::Want_Stdout_Stderr::Test_Context_Instance_Methods

          public(
            :want,
            :want_no_more_lines,
          )

          def expect actual_x
            X_wss_YuckThisAgain.new actual_x
          end

          def eql x
            _guy = X_wss_Eql_Spy.new x
            _receive_guy _guy
          end

          def match x
            _guy = X_wss_Match_Spy.new x
            _receive_guy _guy
          end

          def _receive_guy guy
            remove_instance_variable :@__this_one_mutex
            @predicate_spy = guy
            guy
          end

          def __add_emission_ _em
            @_baked_em_a.push _em ; nil
          end

          # --

          def flush_baked_emission_array
            remove_instance_variable :@_baked_em_a
          end

          attr_reader(
            :predicate_spy,
          )

          self
        end

        _Mock_Context = -> do
          cls
        end

        cls
      end

      def want_no_more_lines
        instance.want_no_more_lines
      end
    end

    class X_wss_Eql_Spy
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

    class X_wss_Match_Spy
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

    class X_wss_YuckThisAgain
      def initialize actual_x
        @actual_value = actual_x ; freeze
      end
      def to pred
        pred.matches? @actual_value
      end
    end

    X_wss_Mock_Emission = ::Struct.new :stream_symbol, :string

  end
end
# #history-A.1: cleaned thing up just for eradication of should but spying is legacy
