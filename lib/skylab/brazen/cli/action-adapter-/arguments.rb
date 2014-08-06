module Skylab::Brazen

  module CLI

    class Action_Adapter_

        class Arguments

          def initialize argv, arg_a
            @arg_a = arg_a ; @argv = argv
            @early_output_segment = @middle_output_segment =
              @late_output_segment = nil
          end

          def execute
            validate_indexes_of_optional_arguments
            prepare_scanners
            error_event = parse_any_required_arguments_off_beginning
            error_event ||= parse_any_required_arguments_off_ending
            error_event || parse_any_optional_arguments
            error_event ||= complain_about_any_extra_arguments
            error_event || finalize_success
          end

        private

          def validate_indexes_of_optional_arguments
            # optional arguments (if any) may occur at the beginning, middle or
            # end of the formal argument list but they must be contiguous with
            # respect to each other. (inspired by the syntax for ruby arg lists)

            # we are ignoring the idea of #globbing for now

            a = @arg_a.length.times.reduce [] do |m, d|
              if ! @arg_a[ d ].is_actually_required
                if m.length.nonzero?
                  m.last == d - 1 or raise say_bad_optional_indexes( m, d )
                end
                m.push d
              end ; m
            end
            @indexes_of_optional_arguments = ( a if a.length.nonzero? ) ; nil
          end

          def say_bad_optional_indexes m, d
            "optional argument '#{ @arg_a.fetch( d ).name_i }' must but did #{
              }not occur immediately after optional argument #{
            }'#{ @arg_a.fetch( m.last ).name_i }'"
          end

          def prepare_scanners
            @arg_a_scan = Crazy_Scanner__.new 0, @arg_a
            @argv_scan = Crazy_Scanner__.new 0, @argv
          end

          def parse_any_required_arguments_off_beginning
            num_leading_required_args = if @indexes_of_optional_arguments
              @indexes_of_optional_arguments.first
            else
              @arg_a.length
            end
            if num_leading_required_args.nonzero?
              @arg_a_scan.x_a_length = num_leading_required_args
              parse_required_segment :'@early_output_segment'
            end
          end

          def parse_any_required_arguments_off_ending
            @num_trailing_required_args = if @indexes_of_optional_arguments
              @arg_a.length - @indexes_of_optional_arguments.last - 1
            else
              0
            end
            if @num_trailing_required_args.nonzero?
              @arg_a_scan.x_a_length = @arg_a.length
              @arg_a_scan.d = @arg_a.length - @num_trailing_required_args
              temporarily_advance_argv_scanner_if_necessary
              parse_required_segment :'@late_output_segment'
            else
              @previous_d = nil
            end
          end

          def temporarily_advance_argv_scanner_if_necessary
            @temporary_d = @argv.length - @num_trailing_required_args
            if @argv_scan.d < @temporary_d
              @previous_d = @argv_scan.d
              @argv_scan.d = @temporary_d
            else
              @previous_d = nil
            end ; nil
          end

          def parse_required_segment i
            begin
              if @argv_scan.unparsed_exists
                accept_monadic_actual_property_value i
              else
                result = build_missing_required_event
                break
              end
            end while @arg_a_scan.unparsed_exists
            result
          end

          def build_missing_required_event
            Missing_.new @arg_a_scan.current_token
          end

          def parse_any_optional_arguments
            if @indexes_of_optional_arguments
              a = @indexes_of_optional_arguments
              @arg_a_scan.d = a.first
              @arg_a_scan.x_a_length = a.first + a.length
              if @previous_d
                @argv_scan.d = @previous_d
                @argv_scan.x_a_length = @temporary_d
              end
              while @argv_scan.unparsed_exists
                if @arg_a_scan.unparsed_exists
                  accept_monadic_actual_property_value :'@middle_output_segment'
                else
                  break
                end
              end
            end
          end

          def accept_monadic_actual_property_value i
            a = instance_variable_get i
            a ||= instance_variable_set i, []
            a.push( @arg_a_scan.gets_one.name_i, @argv_scan.gets_one ) ; nil
          end

          def complain_about_any_extra_arguments
            if @argv_scan.unparsed_exists
              Extra_.new @argv_scan.current_token
            end
          end

          def finalize_success
            @did_succeed = true
            @final_output_iambic = [ * @early_output_segment,
              * @middle_output_segment, * @late_output_segment ]
            PROCEDE_
          end

        public
          def release_result_iambic
            if @did_succeed
              r = @final_output_iambic ; @final_output_iambic = nil ; r
            end
          end
        end

        class Missing_
          def initialize property
            @property = property
          end
          attr_reader :property
          def event_channel_i
            :missing
          end
        end

        class Extra_
          def initialize x
            @x = x
          end
          attr_reader :x
          def event_channel_i
            :extra
          end
        end

        class Crazy_Scanner__ < Brazen_::Entity::Iambic_Scanner
          attr_writer :d, :x_a_length
          attr_reader :d
        end

    end
  end
end
