module Skylab::TMX

  class Operations_::Reports

    class << self
      alias_method :begin, :new
      undef_method :new
    end  # >>

    # -

      def initialize & p
        @_emit = p
      end

      attr_writer(
        :argument_scanner,
      )

      def execute
        __init
        if __parse_all_primary_terms
          __execute_operation
        end
      end

      def __init
        @_found_operation = false
        @_report_name_box = Report_names_box___[]
        NIL
      end

      def __parse_all_primary_terms
        begin
          ok = __parse_one_primary_term
          ok || break
        end until @argument_scanner.no_unparsed_exists
        ok
      end

      def __parse_one_primary_term
        m = @argument_scanner.branch_value_via_match_primary_against PRIMARIES__
        if m
          _ok = send m
          _ok  # #todo
        end
      end

      def __execute_operation

        _term_op_sym = if @_found_operation
          @_operation_symbol
        else
          :list
        end

        send TERMINAL_OPERATIONS___.fetch _term_op_sym
      end

      Description_proc_reader___ = Lazy_.call do
        {
          list: -> y do
            y << "stream the available reports"
          end,

          execute: -> y do
            y << "<report name>   execute a particular report"
          end,

          json_file_stream_by: -> y do
            y << "which item collection to use to populate the report."
          end,

          reverse: -> y do
            y << "(where available) in the lines of output of the report, the"
            y << "order of the items is reversed so the item that used to"
            y << "appear first will now appear last, and so on. (typically this"
            y << "is not exactly the same as simply reversing the order in which"
            y << "the resulting lines are produced, because of spacing, sections.)"
          end,
        }
      end

      PRIMARIES__ = {
        # (for now, ordered aesthetically)
        list: :__when_head_is_list,
        execute: :__when_head_is_execute,
        json_file_stream_by: :__when_head_is_json_file_stream_by,
        reverse: :__when_head_is_reverse,
      }

      def __when_head_is_execute

        if _parse_mutex_operation

          _parse_into( :@_report_normal_symbol,
            :must_be_trueish,
            :use_method, :head_as_normal_symbol,
          )
        end
      end

      def __when_head_is_list
        _parse_mutex_operation
      end

      def __when_head_is_json_file_stream_by

        @argument_scanner.advance_one
        p = @argument_scanner.parse_primary_value :must_be_trueish
        if p
          _add_for_reports p, :json_file_stream_by
          ACHIEVED_
        end
      end

      def __when_head_is_reverse
        @argument_scanner.advance_one
        _add_for_reports false, :be_forwards
        ACHIEVED_
      end

      def _add_for_reports x, k
        ( @__for_reports ||= __default_for_reports )[ k ] = x ; nil
      end

      def __default_for_reports
        o = ForReports___.new
        o.be_forwards = true
        o
      end

      # --

      TERMINAL_OPERATIONS___ = {
        execute: :__execute_report,
        list: :_list,
      }

      def __execute_report

        if __find_report
          __execute_found_report
        else
          __when_unrecognized_report
        end
      end

      def __find_report
        _store :@_found_report_name, @_report_name_box.h_[ @_report_normal_symbol ]
      end

      def __when_unrecognized_report

        box = @_report_name_box
        sym = @_report_normal_symbol

        @_emit.call :error, :expression, :operator_parse_error, :unrecognized_report do |y|

          _name = Common_::Name.via_variegated_symbol sym

          y << "unknown report: #{ _name.as_human.inspect }"

          _p = method :say_arguments_head_

          _buffer = box.to_value_stream.join_into_with_by "", ", ", & _p

          y << "available reports: (#{ _buffer })"
        end

        UNABLE_
      end

      def __execute_found_report

        _const = @_found_report_name.as_camelcase_const_string

        _report_class = Home_::Reports_.const_get _const, false

        _report = _report_class.new( @__for_reports, & @_emit )

        _report.execute
      end

      def _list
        @_report_name_box.to_value_stream
      end

      # -- parsing suppport

      def _parse_mutex_operation

        # assume the argument stream head is cached as a primary symbol
        # and corresponds to a valid sub-operation. these sub-operations
        # are mutually exclusive - you can only ever indicate one.
        # abstraction candidate maybe.

        sym = @argument_scanner.current_primary_symbol

        if @_found_operation && @_operation_symbol != sym
          self._COVER_ME_when_multiple_operations
        else
          @_found_operation = true
          @_operation_symbol = sym
          @argument_scanner.advance_one
          ACHIEVED_
        end
      end

      define_method :_parse_into, DEFINITION_FOR_THE_METHOD_CALLED_PARSE_INTO_

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # -- help screen boilerplate

      def is_branchy
        false
      end

      def description_proc_reader
        Description_proc_reader___[]
      end

      def to_item_normal_tuple_stream
        Stream_.call PRIMARIES__.keys do |sym|
          [ :primary, sym ]
        end
      end

      attr_reader :argument_scanner

    # -

    Report_names_box___ = Lazy_.call do
      Box_via_autoloaderized_module_[ Home_::Reports_ ]
    end

    ForReports___ = ::Struct.new :be_forwards, :json_file_stream_by

    # ==
  end
end
