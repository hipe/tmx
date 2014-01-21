module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Manifest

      class Reduce_ < Agent_

        def initialize y, cache, request, response
          @added_count = 0
          @IO_cache = cache ; @mani_path = request.manifest_path
          @pn = ::Pathname.new @mani_path ; @request = request
          super y, response
        end

        def reduce
          @mani = @IO_cache.lookup_any_cached_manifest_handle_for_pn @pn
          @mani or es = resolve_manifest_with_unsanitized_path
          es || reduce_with_manifest
        end
        def resolve_manifest_with_unsanitized_path
          es = resolve_any_stat
          es || resolve_manifest_with_stat
        end
      private
        def resolve_any_stat
          @stat = ::File.stat @mani_path
          PROCEDE_
        rescue ::Errno::ENOENT => e
          bork e.message
        end
        def resolve_manifest_with_stat
          send :"resolve_manifest_when_path_is_#{ @stat.ftype }"
        end
        def resolve_manifest_when_path_is_directory
          bork "manifest path is directory: #{ @mani_path }"
        end
        def resolve_manifest_when_path_is_file
          _context = Manifest_Handle_Resolution_Context__.new @IO_cache, @pn
          @mani = _context.resolve_any_manifest_handle
          @mani ? PROCEDE_ : GENERAL_ERROR_
        end

        class Manifest_Handle_Resolution_Context__
          def initialize cache, pn
            @fixture_IO_cache = cache ; @pn = pn
          end
          include Mock_System::Instance_Methods__
          def get_system_command_manifest_pn  # #hook-in
            @pn
          end
          def resolve_any_memoized_IO_cache _lookup # #hook-in
            @fixture_IO_cache
          end
        end

        def reduce_with_manifest
          es = prepare_query_params
          es || reduce_with_manifest_when_prepared
        end

        def prepare_query_params
          @rx = ::Regexp.new @request.command_white_filter_regex
          @cd_prefix = @request.chdir_prefix_white_filter
          @prefix_length = @cd_prefix.length
          PROCEDE_
        end

        def reduce_with_manifest_when_prepared
          @scn = @mani.get_command_scanner_scanner
          while (( scn = @scn.gets ))
            cmd = scn.gets  # assume always at least one
            @rx =~ cmd.cmd_s or next  # SCANNERS ARE SO COOL
            begin
              cmd.parse_everything_as_necessary
              prefix = any_prefix cmd
              prefix or next
              add_result_item cmd, prefix
            end while(( cmd = scn.gets ))
          end
          issue_a_notice_if_no_items_were_added
          PROCEDE_
        end

        def issue_a_notice_if_no_items_were_added
          if @added_count.zero?
            @response.add_iambicly_structured_statement :notice, say_none_found
          end
        end

        def say_none_found
          "no commands were found matching the above query."
        end

        def any_prefix cmd
          s = cmd.any_chdir_s
          case @prefix_length <=> s.length
          when -1 ; when_prefix_is_shorter s
          when  0 ; when_prefix_is_same_length s
          end
        end

        def when_prefix_is_shorter s
          if @cd_prefix == s[ 0, @prefix_length ]
            if PATH_SEP__ == s[ @prefix_length ]
              s[ @prefix_length + 1 .. -1  ]
            end
          end
        end

        def when_prefix_is_same_length s
          @cd_prefix == s and ''
        end

        PATH_SEP__ = '/'.freeze

        def add_result_item cmd , pfx  # [#018]:#the-fields-of-a-record-command
          _odfs = cmd.out_dumpfile_s
          _edfs = cmd.err_dumpfile_s
          _ec = cmd.result_code_mixed_string
          @added_count += 1
          @response.add_iambicly_structured_statement(
            :payload, :iambic, :command,
            :command, cmd.cmd_s, :cd_relpath, pfx,
            :any_stdout_path, _odfs,
            :any_stderr_path, _edfs,
            :result_code_x, _ec )
        end
      end
    end
  end
end
