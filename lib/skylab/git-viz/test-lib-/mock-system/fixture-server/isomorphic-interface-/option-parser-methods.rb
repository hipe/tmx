module Skylab::GitViz

  class Test_Lib_::Mock_System::Fixture_Server

    class Isomorphic_Interface_

      # your :#hook-outs are: `error_code_for_general_failure`, @argv

      module Option_Parser_Methods

        def self.apply_iambic_on_client _, mod
          mod.include Option_Parser_Methods
        end

        attr_reader :do_exit_early

      private

        def parse_options
          @op ||= build_option_parser
          parse_options_with_option_parser
        end

        def parse_options_with_option_parser
          @op.parse! @argv
          do_exit_early ? code_for_early_exit : CONTINUE_
        rescue ::OptionParser::ParseError => e
          when_option_parser_parse_error e
        end

        def code_for_early_exit
          self.class::EARLY_EXIT_
        end

        def when_option_parser_parse_error e
          emit_error_string e.message
          error_code_for_option_parser_parse_error
        end

        def error_code_for_option_parser_parse_error
          error_code_for_general_failure
        end

        def error_code_for_general_failure
          self.class::GENERAL_ERROR_
        end

        def build_option_parser
          op = GitViz_._lib.option_parser.new
          alter_default_help op
          formal_parameter_a.each do |param|
            if param.takes_exactly_one_argument
              takes_exactly_one_arg param, op
            elsif param.takes_multiple_arguments
              takes_multiple_args param, op
            else
              takes_no_arg param, op
            end
          end
          op
        end

        def alter_default_help op  # it exits.
          op.on '--help' do
            y = []
            op.summarize do |s|
              s.strip! ; y << s
            end
            emit_info_string "(parameters: #{ y * ', ' })"
            @do_exit_early = true
          end
        end

        def formal_parameter_a
          @formal_parameter_a ||= resolve_some_formal_parameter_a
        end

        def resolve_some_formal_parameter_a
          self.class.get_parameters
        end

        def takes_multiple_args param, op
          _p = if param.is_required
            -> x do
              ( instance_variable_get param.ivar or
                instance_variable_set( param.ivar, [] ) ) << x
            end
          else
            -> x do
              ( instance_variable_get param.ivar ) << x
            end
          end
          op.on "#{ param.CLI_moniker_s }#{ render_param_arg param }", & _p
        end

        def takes_exactly_one_arg param, op
          op.on "#{ param.CLI_moniker_s }#{ render_param_arg param }" do |x|
            instance_variable_set param.ivar, x
          end ; nil
        end

        def render_param_arg param
          " <#{ param.param_i.to_s[ 0 ] }>"
        end

        def takes_no_arg param, op
          op.on "#{ param.CLI_moniker_s }" do
            i = param.ivar
            if instance_variable_defined?( i ) and
                ( d = instance_variable_get( i ) )
              instance_variable_set i, d + 1
            else
              instance_variable_set i, 1
            end
          end ; nil
        end


        def resolve_extra_args
          @argv.length.nonzero? and when_extra_args
        end

        def when_extra_args
          emit_error_string say_unexpected_argument
          error_code_for_extra_args
        end

        def say_unexpected_argument
          "unexpected argument: #{ @argv.first.inspect }"
        end

        def error_code_for_extra_args
          error_code_for_general_failure
        end


        def resolve_missing_args
          missing_a = formal_parameter_a.reduce [] do |a, param|
            param.is_required or next a
            x = instance_variable_get param.ivar
            if ! actual_parameter_value_counts_as_being_provided x
              a << param
            end ; a
          end
          missing_a.length.nonzero? and when_missing_required_params missing_a
        end

        def actual_parameter_value_counts_as_being_provided x
          x
        end

        def when_missing_required_params param_a
          emit_error_string say_missing_required_params param_a
          error_code_for_missing_required_params
        end

        def say_missing_required_params param_a
          s_a = param_a.map( & :CLI_moniker_s )
          1 == param_a.length or many = true
          "please provide the required (option-looking) parameter#{
            many && 's' }: #{
              }#{ many && '(' }#{ GitViz_._lib.oxford_and s_a }#{
               }#{ many && ')' }"
        end

        def error_code_for_missing_required_params
          error_code_for_general_failure
        end

        def get_reconstruct_invocation_argv
          formal_parameter_a.reduce [] do |m, par|
            x = instance_variable_get par.ivar
            x or next m
            if par.takes_exactly_one_argument
              m << par.CLI_moniker_s
              m << x
            elsif par.takes_multiple_arguments
              x.each do |x_|
                m.push par.CLI_moniker_s, x_
              end
            else
              x.times do
                m << par.CLI_moniker_s
              end
            end ; m
          end
        end
      end
    end
  end
end
