module Skylab::Zerk::TestSupport

  module No_Dependencies_Zerk::Features_Injections

    def self.[] tcc
      tcc.send :define_singleton_method, :given, Given___
      tcc.include InstanceMethods___
    end

    # -

      Given___ = -> & p do
        yes = true ; x = nil
        define_method :executed_parse_state do
          if yes
            yes = false
            @ze_FI_DSL_parameters_for_parse = ParametersforParse___.new
            instance_exec( & p )
            x = __ze_FI_flush_executed_parse_state
          end
          x
        end
      end
    # -

    module InstanceMethods___

      # -- expect

      def want_succeeded_
        executed_tuple_.result || fail
      end

      def clientesque_
        executed_tuple_.clientesque
      end

      def operationesque_
        executed_tuple_.operationesque
      end

      # -- DSL

      # ~ setup

      def args_for_CLI * s_a
        @ze_FI_DSL_parameters_for_parse._args_for_CLI = s_a ; nil
      end

      def args_for_API * x_a
        @ze_FI_DSL_parameters_for_parse._args_for_API = x_a ; nil
      end

      def args * s_a
        @ze_FI_DSL_parameters_for_parse.args = s_a ; nil
      end

      def want_failure
        @ze_FI_DSL_parameters_for_parse.do_expect_failure = true ; nil
      end

      # ~ assert

      def scanner_finished_
        _token_scanner_NODEPS_FI.no_unparsed_exists || fail
      end

      def index_is_at_ d
        _token_scanner_NODEPS_FI.instance_variable_get( :@_current_offset ) == d || fail
      end

      def _token_scanner_NODEPS_FI
        innermost_scanner_ executed_parse_state.my_parser.argument_scanner_narrator
      end

      def __ze_FI_flush_executed_parse_state

        params = remove_instance_variable :@ze_FI_DSL_parameters_for_parse
        if params.is_new_way
          __flush_new_way params
        else
          __flush_old_way params
        end
      end

      def __flush_new_way params

        JibbyDibby___.new params, self
      end

      def __flush_old_way params
        _cls = parser_class_

        if params.do_expect_failure
          log = Common_.test_support::Want_Emission::Log.for self
          p = log.handle_event_selectively
        end

        _NoDeps = subject_library_

        _args = _NoDeps::CLI_ArgumentScanner.narrator_for params.args, & p

        parser = _cls.new _args

        _result = parser.execute

        ParseResultState___.new log, _result, parser
      end

      # -- shared state support

      def one_line_for_CLI_
        _expag = self.expression_agent_for_CLI
        _one_line _state_for_CLI, _expag
      end

      def one_line_for_API_
        _expag = self.expression_agent_for_API
        _one_line _state_for_API, _expag
      end

      def _one_line state, expag
        a = state.log.flush_to_array
        1 == a.length || fail
        _em = a[0]
        a = _em.express_into_under [], expag
        1 == a.length || fail
        a[0]
      end

      def value_for_CLI_
        _value_for value_match_for_CLI_
      end

      def value_for_API_
        _value_for value_match_for_API_
      end

      def _value_for vm
        vm.mixed
      end

      def value_match_for_CLI_
        _state_for_CLI.value_match
      end

      def value_match_for_API_
        _state_for_API.value_match
      end

      def _state_for_CLI
        executed_parse_state.executed_parse_state_for_CLI
      end

      def _state_for_API
        executed_parse_state.executed_parse_state_for_API
      end

      def parsation_via_ x, omni, log
        Parsation___.new x, omni, log
      end

      def flush_one_emission_via_findation_
        log = findation_.log
        em = log.gets
        log.gets and fail
        em
      end

      def findation_via_ x, omni, log
        Findation___.new x, omni, log
      end

      # -- setup

      def dup_and_mutate_omni_
        _omni = subject_omni_
        _omni.redefine do |o|
          o.argument_scanner_narrator = _release_narrator_ZE
        end
      end

      def frozen_omni_one_
        Frozen_omni_one[]
      end

      def against_CLI_arguments_ * s_a, & p
        @NARRATOR = subject_library_::CLI_ArgumentScanner.narrator_for s_a, & p
        NIL
      end

      def given_arguments_ * x_a, & p

        No_Dependencies_Zerk::Subject_library_[]
        @NARRATOR = subject_library_::API_ArgumentScanner.narrator_for x_a, & p
        NIL
      end

      def build_new_event_log_
        Common_.test_support::Want_Emission::Log.for self
      end

      def clientesque_primaries_
        these_two_primaries_hashes_.fetch 1
      end

      def operationesque_primaries_
        these_two_primaries_hashes_.fetch 0
      end

      def build_executed_tuple_

        lib = library_one_

        nar = _release_narrator_ZE

        op = lib::Operation.new nar
        cli = lib::Client.new nar

        _prim_for_op = operationesque_primaries_
        _prim_for_client = clientesque_primaries_

        _xx = subject_library_::ArgumentParsingIdioms_via_FeaturesInjections.define do |o|

          o.argument_scanner_narrator = nar

          o.add_primaries_injection _prim_for_op, :_op_injector_
          o.add_injector op, :_op_injector_

          o.add_primaries_injection _prim_for_client, :_cli_injector_
          o.add_injector cli, :_cli_injector_

        end.flush_to_parse_primaries

        ExectionResult___[ _xx, cli, op ]
      end

      def _release_narrator_ZE
        remove_instance_variable :@NARRATOR
      end

      def expression_agent_for_nodeps_CLI_
        No_deps_zerk_[]::CLI_InterfaceExpressionAgent.instance
      end
    end

    # ==

    # ==

    Frozen_omni_one = Lazy_.call do

      _OPERATIONS = {
        xx: :yy,
      }

      _PRIMARIES = {
        zz: :__parse_zz,
      }

      _lib = No_Dependencies_Zerk.lib

      _lib::ArgumentParsingIdioms_via_FeaturesInjections.define do |fi|

        fi.add_hash_based_operators_injection _OPERATIONS, nil, :_INJECTION_0_

        fi.add_lazy_operators_injection_by do |o|
          _h = {
            xx_yy1: :xxx,
            he_ha: :yyy,
          }
          o.operators = Home_::ArgumentScanner::FeatureBranch_via_Hash[ _h ]
          o.injection_symbol = :_INJECTION_1_
        end

        fi.add_lazy_operators_injection_by do |o|
          _h = {
            xx_yy2: :zzz,
          }
          o.operators = Home_::ArgumentScanner::FeatureBranch_via_Hash[ _h ]
          o.injection_symbol = :_INJECTION_2_
        end

        fi.add_primaries_injection _PRIMARIES, nil, :_INJECTION_3_
      end
    end

    # ==

    class JibbyDibby___

      def initialize params, ctx

        @_CLI = :__initially_CLI
        @_API = :__initially_API
        @DANGER_test_context = ctx

        @params = params
      end

      def executed_parse_state_for_CLI
        send @_CLI
      end

      def executed_parse_state_for_API
        send @_API
      end

      def __initially_CLI
        @_CLI = :__memoized_CLI
        _s_a = @params.__release_args_for_CLI_
        @__memoized_CLI = _same_thing _s_a, :CLI_ArgumentScanner
        send @_CLI
      end

      def __initially_API
        @_API = :__memoized_API
        _x_a = @params.__release_args_for_API_
        @__memoized_API = _same_thing _x_a, :API_ArgumentScanner
        send @_API
      end

      def _same_thing x_a, c

        _arg_scn_cls = No_Dependencies_Zerk.lib.const_get c, false

        if @params.do_expect_failure
          log = @DANGER_test_context.build_new_event_log_
          any_p = log.handle_event_selectively
        end

        nar = _arg_scn_cls.narrator_for x_a, & any_p
        a = @DANGER_test_context.story_time_ nar
        a.first == :story_ZE || fail

        LogAndValueMatch___.new( log, * a[1..-1] )
      end

      def __memoized_CLI
        @__memoized_CLI
      end

      def __memoized_API
        @__memoized_API
      end
    end

    LogAndValueMatch___ = ::Struct.new(
      :log,
      :value_match,
    )

    # ==

    class ParametersforParse___

      def initialize
        @is_new_way = nil
      end

      def _args_for_CLI= s_a
        _be_new_way
        @_args_for_CLI = s_a
      end

      def _args_for_API= x_a
        _be_new_way
        @_args_for_API = x_a
      end

      def _be_new_way
        if ! @is_new_way
          false == @is_new_way && fail
          @is_new_way = true
        end
      end

      def args= s_a
        @is_new_way && fail
        @is_new_way = false
        @args = s_a
      end

      def __release_args_for_CLI_
        remove_instance_variable :@_args_for_CLI
      end

      def __release_args_for_API_
        remove_instance_variable :@_args_for_API
      end

      attr_accessor(
        :do_expect_failure,
      )
      attr_reader(
        :args,
        :_args_for_API,
        :_args_for_CLI,
        :is_new_way,
      )
    end

    ParseResultState___ = ::Struct.new(
      :log,
      :result,
      :my_parser,
    )

    # ==

    class Parsation___

      def initialize x, omni, log
        @log = log
        @omni = omni
        @result = x
      end

      def token_scanner
        # (as innermost_scanner_)
        @omni.argument_scanner_narrator.token_scanner
      end

      attr_reader :log, :omni, :result
    end

    ExectionResult___ = ::Struct.new :result, :clientesque, :operationesque

    Findation___ = ::Struct.new :result, :omni, :log

    # ==
  end
end
# #history: abstracted from a test
