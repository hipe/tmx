module Skylab::TaskExamples::TestSupport

  module Task_Types

    class << self

      def [] tcc

        tcc.extend Module_Methods___
        tcc.include Instance_Methods___
        NIL_
      end
    end  # >>

    module Module_Methods___

      def shared_state_  # "dangerous memoize" the state. (see [#ts-042])
        x = nil
        define_method :state_ do
          if ! x
            x = __build_state
          end
          x
        end
      end

      def memoize_ sym, & p
        define_method sym, Callback_::Memoize[ & p ]
      end
    end

    module Instance_Methods___

      # ~

      td = nil

      define_method :prepare_build_directory_ do

        if td
          if ( ! td.be_verbose ) != ( ! do_debug )
            td = td.new_with :be_verbose, do_debug
          end
        else
          td = build_build_directory_controller_
        end

        td.prepare

        NIL_
      end

      def build_build_directory_controller_

        _path = BUILD_DIR

        TestSupport_.tmpdir.new_with(
          :path, _path,
          :be_verbose, do_debug,
          :debug_IO, debug_IO,
        )
      end

      # ~

      def run_file_server_if_not_running_

        Run_static_file_server_if_necessary_.call do
          [ do_debug, debug_IO ]
        end
      end

      # ~

      def file_exists_ path
        ::File.exist? path
      end

      def read_file_ path
        ::File.read path
      end

      # ~ assert about "hard failure" (which means exceptions raised (for now))

      def expect_missing_required_attributes_are_ * sym_a

        begin
          execute_
        rescue ::RuntimeError => e
        end

        if 1 < sym_a.length
          _s = 's'
        end

        _s_ = sym_a.map do | sym |
          ::Regexp.escape sym.id2name
        end.join ', '

        _rx = /\A[a-z ]+ task missing required attribute#{ _s }: #{ _s_ }\z/

        e.message.should match _rx
      end

      def expect_strong_failure_with_message_ x

        expect_strong_failure_with_message_by_ x do
          execute_
        end
      end

      def expect_strong_failure_with_message_by_ x

        begin
          yield
        rescue ::RuntimeError => e
        end

        if x.respond_to? :named_captures
          e.message.should match x
        else
          e.message.should eql x
        end
      end

      # ~

      def fails_
        state_.result_x.should eql false
      end

      def succeeds_
        state_.result_x.should eql true
      end

      def expect_ * x_a
        _expect x_a
      end

      def expect_only_ * x_a

        _expect x_a

        if @_emission_stream_controller.unparsed_exists
          fail ___say_had_more
        end
      end

      def expect_eventually_ * x_a
        sym = x_a.first

        st = emission_stream_controller_
        begin
          if sym == st.current_token.stream_symbol
            break
          end
          st.advance_one
          redo
        end while nil
        _expect x_a
      end

      def ___say_had_more
        "had more"
      end

      def _expect x_a

        if emission_stream_controller_.unparsed_exists

          __expect_when_one x_a
        else
          fail ___say_had_none x_a
        end
      end

      def ___say_had_none x_a
        "had none, expected #{ x_a.inspect }"
      end

      def __expect_when_one x_a

        exp = TestSupport_::Expect_Stdout_Stderr::Expectation.via_args x_a

        em = @_emission_stream_controller.gets_one

        sym = exp.stream_symbol
        if sym
          em.stream_symbol.should eql sym
        end

        s = em.text
        if exp.expect_is_styled
          s = ___unstyle_styled s
          if ! s
            self._WAS_NOT_STYLED
          end
        end

        s.chomp!  # read all about it in [#ts-029]
        send exp.method_name, s, exp.pattern_x

        NIL_
      end

      def ___unstyle_styled s
        TestLib_::Brazen[]::CLI_Support::Styling::Unstyle_styled[ s ]
      end

      def emission_stream_controller_
        @_emission_stream_controller ||= ___build_ESC
      end

      def ___build_ESC

        ESC___.via_array state_.emission_array
      end

      def sout_serr_expect_given_string act_s, exp_s
        act_s.should eql exp_s
      end

      def sout_serr_expect_given_regex act_s, rx
        act_s.should match rx
      end

      def __build_state

        emissions = []

        x = __execute_into emissions

        Result_State___.new emissions.freeze, x
      end

      def execute_

        __execute_into NIL_
      end

      def __execute_into emissions

        _ctx = context_

        task = build_task_ emissions

        before_execution_

        task.invoke _ctx

      end

      def build_task_with_context_

        task = build_task_
        task.context = context_
        task
      end

      def build_task_ emissions=nil

        _cls = subject_class_

        _args = build_arguments_

        _cls.new _args do | t |

          t.on_all do | ev |

            if do_debug
              debug_IO.puts [ ev.stream_symbol, ev.text ].inspect
            end

            emissions.push Emission___.new( ev.text, ev.stream_symbol )

            NIL_
          end
        end
      end

      def before_execution_
        NIL_
      end
    end

    class ESC___ < Callback_::Polymorphic_Stream

      def advance_to_first sym

        begin
          guy = current_token
          if sym == guy.stream_symbol
            break
          end
          advance_one
          redo
        end while nil
        NIL_
      end
    end

    Emission___ = ::Struct.new :text, :stream_symbol

    class Result_State___

      def initialize em_a, x
        @emission_array = em_a
        @result_x = x
        freeze
      end

      attr_reader(
        :emission_array,
        :result_x,
      )
    end
  end
end
