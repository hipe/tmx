module Skylab::Zerk::TestSupport

  module Non_Interactive_CLI::Fail_Early

    def self.[] tcc
      tcc.include self
    end

    # -

      def invoke * argv
        @_ze_niCLI_setup = Setup___.new argv ; nil
      end

      def expect_empty_puts
        expect nil
      end

      def expect_on_stderr exp_x
        @_ze_last_stream = :serr
        expect exp_x
      end

      def expect exp_x
        @_ze_niCLI_setup.add_expectation exp_x, :puts, @_ze_last_stream
        NIL
      end

      def expect_failed
        InvocationUnderExpectations__.new( self ).execute.__expect_failed
      end

      def expect_succeeded
        InvocationUnderExpectations__.new( self ).execute.__expect_succeeded
      end
    # -

    # ==

    class InvocationUnderExpectations__

      def initialize tc

        @setup = tc.remove_instance_variable :@_ze_niCLI_setup
        @test_context = tc
      end

      def execute
        __init_CLI_and_spies
        __invoke_under_expectations
        self
      end

      def __expect_failed
        if @_exitstatus.zero?
          fail( * @_spy.__when_expected_failed )
        end
      end

      def __expect_succeeded
        if @_exitstatus.nonzero?
          fail( * @_spy.__when_expected_succeeded )
        end
      end

      def __invoke_under_expectations
        @_exitstatus = @_CLI.invoke @setup.ARGV
        @_spy.finished_invoking_notify
        NIL
      end

      def __init_CLI_and_spies

        _CLI_class_ish = @test_context.subject_CLI

        spy = Spy___.new @setup, @test_context

        __pn_s_a = __program_name_string_array

        @_CLI = _CLI_class_ish.new(
          :_ze_NO_,
          spy.sout_stream_proxy,
          spy.serr_stream_proxy,
          __pn_s_a,
        )

        @_spy = spy
        NIL
      end

      def __program_name_string_array
        if @test_context.respond_to? :program_name_string_array
          @test_context.program_name_string_array
        else
          %w( ze-pnsa )
        end
      end
    end

    # ==

    class Spy___

      def initialize setup, tc

        a = setup.expectations
        if ! a
          self._NO_PROBLEM_just_use_empty_a
        end

        @_expectations_queue = Common_::Polymorphic_Stream.via_array a

        @do_debug = tc.do_debug
        if @do_debug
          @debug_IO = tc.debug_IO
        end

        has = setup.has

        _sout_spy = if has[ :sout ]
          SoutSpy__[].new do |o|
            o.receive = method :_receive
          end
        else
          Expect_nothing_on__[ :sout ]
        end

        _serr_spy = if has[ :serr ]
          SerrSpy__[].new do |o|
            o.receive = method :_receive
          end
        else
          Expect_nothing_on__[ :serr ]
        end

        @_sout_spy = _sout_spy
        @_serr_spy = _serr_spy
      end

      def _receive s, method_name, stream_sym

        if @do_debug
          @debug_IO.puts [ s, method_name, stream_sym ].inspect
        end

        if @_expectations_queue.no_unparsed_exists
          fail( * __when_extra_emission( [ s, method_name, stream_sym ] ) )
        else
          exp_x, exp_method_name, exp_stream_sym = @_expectations_queue.gets_one
          if exp_stream_sym == stream_sym
            if exp_method_name == method_name
              if exp_x
                if exp_x.respond_to? :ascii_only?
                  if exp_x != s
                    fail( * _when_wrong_content( [ s, method_name, stream_sym ], exp_x ) )
                  end
                elsif exp_x.respond_to? :named_captures
                  if exp_x !~ s
                    fail( * _when_wrong_content( [ s, method_name, stream_sym ], exp_x ) )
                  end
                else
                  ::Kernel._K
                end
              else
                if s
                  fail( * __when_expected_empty( [ s, method_name, stream_sym ] ) )
                end
              end
            else
              fail( * __when_wrong_method( [ s, method_name, stream_sym ], exp_method_name ) )
            end
          else
            fail( * __when_wrong_stream( [ s, method_name, stream_sym ], exp_stream_sym ) )
          end
        end
        NIL
      end

      def __when_expected_empty three
        _common "expected a blank line for #{ three.inspect }"
      end

      def _when_wrong_content three, exp_x
        _common_wrong :content, three, exp_x
      end

      def __when_wrong_method three, exp_x
        _common_wrong :method, three, exp_x
      end

      def __when_wrong_stream three, exp_x
        _common_wrong :stream, three, exp_x
      end

      def _common_wrong which_sym, three, exp_x
        _common "expected #{ which_sym } to match #{ exp_x.inspect } of emission #{ three.inspect }"
      end

      def finished_invoking_notify
        if @_expectations_queue.no_unparsed_exists
          NIL
        else
          fail( * __when_missing_emission )
        end
      end

      def __when_missing_emission
        _tuple = @_expectations_queue.current_token
        _common "missing expected emission: #{ tuple.inspect }"
      end

      def __when_extra_emission tuple
        _common "unexpected emission: #{ tuple.inspect }"
      end

      def __when_expected_succeeded
        _common "expected zero exitstatus, had #{ @_exitstatus }"
      end

      def __when_expected_failed
        _common "expected nonzero exitstatus, had zero"
      end

      def _common msg
        [ ExpectationFailure___, msg ]
      end

      # -- simple readers

      def serr_stream_proxy
        @_serr_spy.stream_proxy
      end

      def sout_stream_proxy
        @_sout_spy.stream_proxy
      end
    end

    ExpectationFailure___ = ::Class.new ::RuntimeError  # publicize whenver if you really want to

    # ==

    # ==

    class Setup___

      def initialize argv
        @ARGV = argv
        @expectations = []
        @has = {}
      end

      def add_expectation exp_x, method_name, sout_or_serr
        @has[ sout_or_serr ] = true
        @expectations.push [ exp_x, method_name, sout_or_serr ]  # here
        NIL
      end

      attr_reader(
        :has,
        :ARGV,
        :expectations,
      )
    end

    # ==

    Expect_nothing_on__ = -> do

      h = {}

      expect_nothing = -> shape, stream_sym do
        ::Kernel._K
      end

      -> sym do
        h.fetch sym do
          x = StreamSpy__.new do |o|
            o.stream_symbol = sym
            o.receive = expect_nothing
          end
          h[ sym ] = x
          x
        end
      end
    end.call

    SoutSpy__ = Lazy_.call do
      StreamSpy__.new do |o|
        o.stream_symbol = :sout
      end
    end

    SerrSpy__ = Lazy_.call do
      StreamSpy__.new do |o|
        o.stream_symbol = :serr
      end
    end

    class StreamSpy__

      def initialize
        yield self
        freeze
      end

      def new
        otr = dup
        yield otr
        otr
      end

      def receive= p
        @stream_proxy = StreamProxy___.new p, @stream_symbol
        p
      end

      attr_writer(
        :stream_symbol,
      )

      attr_reader(
        :stream_proxy,
        :stream_symbol,
      )
    end

    # ==

    class StreamProxy___

      def initialize p, k
        @_receive = p
        @_stream_symbol = k
      end

      def puts s=nil
        @_receive[ s, :puts, @_stream_symbol ]
        NIL
      end
    end

    # ==

    Result___ = ::Struct.new :exitstatus

    # ==
  end
end
