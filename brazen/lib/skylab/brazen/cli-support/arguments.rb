module Skylab::Brazen

  module CLI_Support
    # ->
      module Arguments

        # (all "normalization")

        class Normalization  # :[#057].

          # NOTE this is similar to but not the same as [#ze-022.4]
          # isomorphic method arguments.
          #
          # given one array of formal parameters and one ARGV-like array,
          # parse the arguments off the ARGV and into some kind of store
          # (explained below) taking into account requireds, optionals,
          # and globs. (parsing flags is adjacent to this scope).
          #
          # there are multiple kinds of "parameter store" we could
          # potentially assemble for:
          #
          # 1) (the default, classic style for [br]): build an *iambic*
          #    array suitible for a "backbound" call to a [br]-style API.
          #
          # 2) assemble them into a random-accessible box of qualified
          #    knownness. (if you want a hash, use this).
          #
          # 3) if your args are being "assembled" for a proc-like call
          #    *that has the appropriate syntax suggested by the formal
          #     sytnax*, then you use use the argv as-is.
          #
          # (1) & (2) are implemented. (3) hasn't been needed yet.

          class << self
            alias_method :via_properties, :new
            undef_method :new
          end  # >>

          def initialize prp_a
            prp_a or self._SANITY

            @_accept = :__accept_for_iambic

            @formals = prp_a

            @early_output_segment = nil
            @late_output_segment = nil
            @middle_output_segment = nil

            ___validate_indexes_of_optional_arguments
          end

          def ___validate_indexes_of_optional_arguments

            # optional arguments (if any) may occur at the beginning, middle or
            # end of the formal argument list but they must be contiguous with
            # respect to each other. (inspired by the syntax for ruby arg lists)

            # we are ignoring the idea of #globbing for now

            Require_fields_lib_[]

            a = @formals.length.times.reduce [] do |m, d|

              prp = @formals.fetch d
              if Field_::Is_effectively_optional[ prp ]
                if m.length.nonzero?
                  if m.last != d - 1
                    raise Syntax_Syntax_Error, ___say_bad_optional_indexes( m, d )
                  end
                end
                m.push d
              end ; m
            end
            @indexes_of_optional_arguments = ( a if a.length.nonzero? ) ; nil
          end

          def ___say_bad_optional_indexes m, d
            "optional argument '#{ @formals.fetch( d ).name_symbol }' must but did #{
              }not occur immediately after optional argument #{
            }'#{ @formals.fetch( m.last ).name_symbol }'"
          end

          def be_for_random_access
            @_random_access_box = nil  # careful, this might be proto
            @_accept = :__accept_for_random_access
          end

          # --

          def any_error_event_via_validate_x argv
            via_argv( argv ).execute
          end

          def via_argv argv
            otr = dup
            otr.init_copy_via_argv argv
            otr
          end

          def init_copy_via_argv argv
            @argv = argv ; nil
          end
          protected :init_copy_via_argv

          def execute
            prepare_streams
            ev = parse_any_required_arguments_off_beginning
            ev ||= parse_any_required_arguments_off_ending
            ev || parse_any_optional_arguments
            ev ||= complain_about_any_extra_arguments
            ev || finalize_success
          end

        private

          def prepare_streams
            @arg_a_scan = Crazy_Scanner__.via_array @formals
            @argv_scan = Crazy_Scanner__.via_array @argv
          end

          def parse_any_required_arguments_off_beginning
            num_leading_required_args = if @indexes_of_optional_arguments
              @indexes_of_optional_arguments.first
            else
              @formals.length
            end
            if num_leading_required_args.nonzero?
              @arg_a_scan.x_a_length = num_leading_required_args
              parse_required_segment :'@early_output_segment'
            end
          end

          def parse_any_required_arguments_off_ending
            @num_trailing_required_args = if @indexes_of_optional_arguments
              @formals.length - @indexes_of_optional_arguments.last - 1
            else
              0
            end
            if @num_trailing_required_args.nonzero?
              @arg_a_scan.x_a_length = @formals.length
              @arg_a_scan.d = @formals.length - @num_trailing_required_args
              temporarily_advance_argv_stream_if_necessary
              parse_required_segment :'@late_output_segment'
            else
              @previous_d = nil
            end
          end

          def temporarily_advance_argv_stream_if_necessary
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
                _accept i
              else
                result = build_missing_required_event
                break
              end
            end until @arg_a_scan.no_unparsed_exists
            result
          end

          def build_missing_required_event
            Missing_.new @arg_a_scan.head_as_is
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
                  _accept :'@middle_output_segment'
                else
                  break
                end
              end
            end
          end

          def _accept sym

            prp = @arg_a_scan.gets_one

            if Field_::Takes_many_arguments[ prp ]
              if @arg_a_scan.unparsed_exists
                self._DO_ME
              end
              _x = @argv_scan.flush_remaining_to_array  # naive implementation
              send @_accept, _x, prp, sym

            else
              send @_accept, @argv_scan.gets_one, prp, sym
            end

            NIL_
          end

          # --

          def __accept_for_iambic x, prp, sym

            a = instance_variable_get sym
            a ||= instance_variable_set sym, []
            a.push prp.name_symbol, x ; nil
          end

          def __accept_for_random_access x, prp, _sym

            _bx = ( @_random_access_box ||= Common_::Box.new )
            _qkn = Common_::Qualified_Knownness.via_value_and_association( x, prp )
            _bx.add prp.name_symbol, _qkn ; nil
          end

          # --

          def complain_about_any_extra_arguments
            if @argv_scan.unparsed_exists
              Extra_.new @argv_scan.head_as_is
            end
          end

          def finalize_success
            @did_succeed = true
            NIL_  # CONTINUE_
          end

        public

          def release_result_iambic

            if @did_succeed

              _a = remove_instance_variable :@early_output_segment
              _b = remove_instance_variable :@middle_output_segment
              _c = remove_instance_variable :@late_output_segment
              [ * _a, * _b, * _c ]
            end
          end

          def release_random_access_box
            remove_instance_variable :@_random_access_box
          end

          attr_reader(
            :formals,
          )

          # ==

          class Missing_
            def initialize property
              @property = property
            end
            attr_reader :property
            def terminal_channel_i
              :missing
            end
          end

          class Extra_
            def initialize x
              @x = x
            end
            attr_reader :x
            def terminal_channel_i
              :extra
            end
          end

          class Crazy_Scanner__ < Common_::Scanner  # assumes via array!
            attr_writer :d, :x_a_length
            attr_reader :d
          end

          Syntax_Syntax_Error = ::Class.new ::RuntimeError
        end
      end
    # -
  end
end
