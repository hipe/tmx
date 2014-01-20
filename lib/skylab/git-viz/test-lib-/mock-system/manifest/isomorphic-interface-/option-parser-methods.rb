module Skylab::GitViz

  class Test_Lib_::Mock_System::Manifest

    class Isomorphic_Interface_

      # your :#hook-outs are: `error_code_for_general_failure`, @argv

      module Option_Parser_Methods

        def self.apply_iambic_on_client _, mod
          mod.include Option_Parser_Methods
        end

      private

        def parse_options
          @op ||= build_option_parser
          parse_options_with_option_parser
        end

        def parse_options_with_option_parser
          @op.parse! @argv
          PROCEDE_
        rescue ::OptionParser::ParseError => e
          when_option_parser_parse_error e
        end

        def when_option_parser_parse_error e
          emit_error_string e.message
          error_code_for_option_parser_pare_error
        end

        def error_code_for_option_parser_pare_error
          error_code_for_general_failure
        end

        def error_code_for_general_failure
          GENERAL_ERROR_
        end


        def build_option_parser
          op = GitViz::Lib_::OptionParser[].new
          formal_parameter_a.each do |param|
            if param.does_take_argument
              takes_arg param, op
            else
              takes_no_arg param, op
            end
          end
          op
        end

        def formal_parameter_a
          @formal_parameter_a ||= resolve_some_formal_parameter_a
        end

        def resolve_some_formal_parameter_a
          self.class.get_parameters
        end

        def takes_arg param, op
          _suffix = " <#{ param.param_i.to_s[ 0 ] }>"
          op.on "#{ param.CLI_moniker_s }#{ _suffix }" do |x|
            instance_variable_set param.ivar, x
          end ; nil
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
              }#{ many && '(' }#{ say_oxford_and s_a }#{ many && ')' }"
        end
        def say_oxford_and a
          say_oxford OXFORD_AND_P__, a
        end
        def say_oxford p, a
          if a.length.zero? then say_oxford_none else
            last = a.length - 1
            a.each_with_index.reduce( [ a.shift ] ) do |m, (s, d)|
              m << p[ last - d ] ; m << s ; m
            end * ''
          end
        end

        build_oxford_h = -> final, separator do
          h = { 0 => nil, 1 => final }
          h.default_proc = ->( * ) { separator }
          h.method :[]
        end
        OXFORD_AND_P__ = build_oxford_h[ ' and ', ', ' ]

        def say_oxford_none
          '[none]'
        end

        def error_code_for_missing_required_params
          error_code_for_general_failure
        end


        def get_reconstruct_invocation_argv
          formal_parameter_a.reduce [] do |m, par|
            x = instance_variable_get par.ivar
            x or next m
            if par.does_take_argument
              m << par.CLI_moniker_s
              m << x
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
