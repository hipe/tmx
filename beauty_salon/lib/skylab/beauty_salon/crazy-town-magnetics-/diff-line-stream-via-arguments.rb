module Skylab::BeautySalon

  class CrazyTownMagnetics_::DiffLineStream_via_Arguments < Common_::MagneticBySimpleModel

    # -

      # this is the "glue" magnetic. stay close to the [#025] algorithm

      def initialize
        super
      end

      attr_writer(
        :file_path_upstream,
        :code_selector_string,
        :replacement_function_string,
        :report,
        :filesystem,
        :listener,
      )

      def execute
        if __report_name_was_provided
          __when_report
        elsif __resolve_file_changes_for_every_file
          __flush_stream_of_diff_lines
        end
      end

      def __when_report
        CrazyTownMagnetics_::Result_via_ReportName.call_by do |o|
          o.report_name = @report
          o.listener = @listener
        end
      end

      def __report_name_was_provided
        @report
      end

      def __resolve_file_changes_for_every_file
        if __parse_those_two_things
          __do_resolve_file_changes_for_every_file
        end
      end

      def __flush_stream_of_diff_lines

        CrazyTownMagnetics_::DiffLineStream_via_FileChanges.call_by do |o|
          o.file_changes = remove_instance_variable :@__file_changes
          o.listener = @listener
        end
      end

      def __do_resolve_file_changes_for_every_file

        io = remove_instance_variable :@file_path_upstream

        _line = io.gets
        __really_do_resolve_file_changes_for_every_file _line, io
      rescue ::Errno::EISDIR => e
        _exception e
      end

      def __really_do_resolve_file_changes_for_every_file path, io

        if path.frozen?  # assume ARGV
          chomp = EMPTY_P_
          close = EMPTY_P_
        else
          chomp = -> { path.chomp! }
          close = -> { io.close }
        end

        fcx = FileChangesList___.new
        begin
          chomp[]
          fc = CrazyTownMagnetics_::FileChanges_via_Path_and_Function_and_Selector.call_by do |o|
            o.path = path
            o.code_selector = @_code_selector
            o.replacement_function = @_replacement_function
            o.filesystem = @filesystem
            o.listener = @listener
          end
          if ! fc
            fcx = nil
            break
          end
          fcx.__add_ fc
          line = io.gets
        end while line
        close[]
        _store :@__file_changes, fcx
      end

      def __parse_those_two_things
        @_replacement_function = :_repl_func_placeholder_
        @_code_selector = :_code_selector_placeholder_
        ACHIEVED_
      end

      # -- A.

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      define_method :_exception, DEFINITION_FOR_THE_METHOD_CALLED_EXCEPTION_

    # -

    class FileChangesList___

      def initialize
        @count = 0
        @paths = []
        @_a = []
      end

      def __add_ fc
        @count += 1
        @paths.push fc.path
        @_a.push fc ; nil
      end

      def fetch d
        @_a.fetch d
      end

      attr_reader(
        :count,
        :paths,
      )
    end

    # ==

    # ==
    # ==
  end
end
# #born.
