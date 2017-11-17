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

      def argument_scanner_narrator= as
        @argument_scanner = as  # while #open [#ze-068]
      end

      def execute
        __init
        if __parse_all_primary_terms
          __execute_operation
        end
      end

      def __init
        @_found_operation = false
        # @_MARKED_report_name_box = Report_names_box___[]

        NIL
      end

      def __parse_all_primary_terms

        @_matcher = @argument_scanner.matcher_for(
          :primary, :value, :against_hash, PRIMARIES__ )

        begin
          ok = __parse_one_primary_term
          ok || break
        end until @argument_scanner.no_unparsed_exists

        ok
      end

      def __parse_one_primary_term
        m = @_matcher.gets
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
          __parse_report_loadable_reference_from_head
        end
      end

      def __parse_report_loadable_reference_from_head

        _COL = _report_name_collection

        lt = @argument_scanner.match_branch(
          :business_item, :value, :against_branch, _COL
        )

        if lt
          @argument_scanner.advance_one
          @__report_loadable_reference = lt
          ACHIEVED_
        else
          lt
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
        list: :__list,
      }

      def __execute_report

        lt = remove_instance_variable :@__report_loadable_reference

        _nm = Common_::Name.via_slug lt.asset_reference.entry_group_head

        _const = _nm.as_camelcase_const_string

        _report_class = lt.module.const_get _const, false

        _report = _report_class.new( @__for_reports, & @_emit )

        _report.execute
      end

      def __list
        _report_name_collection.to_slug_stream
      end

      def _report_name_collection
        Report_name_collection___[]
      end

      # -- parsing suppport

      def _parse_mutex_operation

        # assume the argument scanner head is cached as a primary symbol
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

      # -- help screen boilerplate

      def is_branchy
        false
      end

      def description_proc_reader_for_didactics
        Description_proc_reader___[]
      end

      def to_item_normal_tuple_stream_for_didactics
        Stream_.call PRIMARIES__.keys do |sym|
          [ :primary, sym ]
        end
      end

      attr_reader :argument_scanner

    # -

    # ==

    Report_name_collection___ = Lazy_.call do

      Zerk_::ArgumentScanner::FeatureBranch_via_AutoloaderizedModule.define do |o|

        o.module = Home_::Reports_

        o.channel_for_unknown_by do |idea|

          chan = idea.get_channel
          d = 2
          chan[ d ] = { parse_error: :operator_parse_error }.fetch chan.fetch d
          chan
        end

        o.express_unknown_by do |oo|

          oo.express_unknown_item_smart_prefixed "unknown report"
          oo.express_via_template "available reports: {{ say_splay }}"
        end

        o.sub_branch_const = :Actions
      end
    end

    # ==

    ForReports___ = ::Struct.new :be_forwards, :json_file_stream_by

    # ==
  end
end
