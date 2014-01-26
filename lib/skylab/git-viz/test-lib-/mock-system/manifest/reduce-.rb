module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Manifest

      class Reduce_ < Agent_

        def initialize y, cache, request, handlers, response
          @added_count = 0 ; @handlers = handlers
          @IO_cache = cache ; @mani_path = request.manifest_path
          @pn = ::Pathname.new @mani_path ; @request = request
          init_handlers handlers
          super y, response
        end
      private
        def init_handlers handlers
          h = Handlers__.new
          h.set :parse_error, method( :handle_parse_error )
          h.glom handlers
          @handlers = h
        end
        class Handlers__ < GitViz::Lib_::Handlers
          def initialize
            super parse_error: { unexpected_term: nil }
          end
        end
        def handle_parse_error ex
          msg, normd_err_class_bn, path, line, line_no, column = ex.to_a
          @response.add_iambicly_structured_statement :error, :iambic,
            :manifest_parse, normd_err_class_bn, msg, :path, path, :line, line,
            :line_no, line_no, :column, column
          MANIFEST_PARSE_ERROR_
        end
      public

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
          @IO_cache.retrieve_or_init do |o|
            o.IO_class = Manifest::Handle
            o.IO_key = @pn
            o.parse_all_ASAP = true
            o.when_retrieve_existing= method :use_cached_mani_from_IO_cache
            o.when_created_new= method :created_new_mani_from_IO_cache
            o.handlers = @handlers
          end
        end
        def use_cached_mani_from_IO_cache mani
          @y << "(using cached manifest parse tree)"
          @mani = mani ; PROCEDE_
        end
        def created_new_mani_from_IO_cache mani
          if (( @mani = mani )).entry_count.zero?
            when_created_manifest_entry_count_is_zero
          else
            when_created_manifest_entry_count_is_nonzero
          end
        end
        def when_created_manifest_entry_count_is_zero
          bork "no entries in manifest file, all queries destined to fail #{
            }- #{ @pn }"
          GENERAL_ERROR_
        end
        def when_created_manifest_entry_count_is_nonzero
          @y << "parsed #{ @mani.manifest_summary } in #{ @pn }"
          PROCEDE_
        end
        def parse_error_from_IO_cache pe
          render_parse_error_as_multiline pe
          GENERAL_ERROR_
        end
        def render_parse_error_as_multiline pe
          @y << "failed to parse #{ pe.path }"
          prefix = "#{ pe.line_no }:"
          @y << "#{ prefix }#{ pe.line }"
          d = pe.column
          @y << "#{ ' ' * prefix.length }#{ '-' * ( d - 1 ) }^"
          @y << pe.message ; nil
        end
        def reduce_with_manifest
          es = prepare_query_params
          es || reduce_with_manifest_when_prepared
        end

        def prepare_query_params
          es = prepare_volatile_query_params
          es || prepare_deterministic_query_params
        end

        def prepare_volatile_query_params
          @cmd_wht_rx_ex_a = nil
          @cmd_wht_rx_a = @request.command_white_filter_regex_a.reduce [] do |m, rx_s|
            attempt_regex rx_s, -> rx do
              m << rx
            end, -> ex do
              (( @cmd_wht_rx_ex_a ||= [] )) << [ rx_s, ex ] ; m
            end
          end
          @cmd_wht_rx_ex_a ? when_regexp_exceptions : PROCEDE_
        end

        def attempt_regex rx_s, yes_p, no_p
          yes_p[ ::Regexp.new rx_s ]
        rescue ::RegexpError => ex
          no_p[ ex ]
        end

        def when_regexp_exceptions
          @cmd_wht_rx_ex_a.each do |(s, ex)|
            @response.add_iambicly_structured_statement :error,
              say_cmd_white_rx_ex( s, ex )
          end
          GENERAL_ERROR_
        end
        def say_cmd_white_rx_ex input_s, ex
          param = Prepare_.lookup_parameter :command_white_filter_regex
          "can't make #{ param.as_human_moniker } from #{ input_s.inspect }#{
            }- #{ ex.message }"
        end

        def prepare_deterministic_query_params
          @cd_prefix = @request.chdir_prefix_white_filter
          @prefix_length = @cd_prefix.length
          PROCEDE_
        end

        def reduce_with_manifest_when_prepared
          @scn = @mani.get_command_scanner_scanner
          while (( scn = @scn.gets ))
            cmd = scn.gets  # assume always at least one
            _ok = command_string_does_pass_white_or_black_filters cmd.cmd_s
            _ok or next  # THIS IS WHY SCANNERS ROCK
            begin
              ec = cmd.parse_everything_as_necessary
              ec and break
              prefix = any_prefix cmd
              prefix or next
              add_result_item cmd, prefix
            end while(( cmd = scn.gets ))
            ec and break
          end
          ec || check_if_no_items_where_added
        end

        def command_string_does_pass_white_or_black_filters cmd_s
          _rx_that_it_did_not_match = @cmd_wht_rx_a.detect do |rx|
            rx !~ cmd_s
          end
          ! _rx_that_it_did_not_match
        end

        def check_if_no_items_where_added
          if @added_count.zero?
            @response.add_iambicly_structured_statement :notice, say_none_found
            PROCEDE_
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
          if (( ft = cmd.marshalled_freetags ))
            ft_a = [ :marshalled_freetags, ft ]
          end
          @added_count += 1
          @response.add_iambicly_structured_statement(
            :payload, :iambic, :command,
            :command, cmd.cmd_s, :cd_relpath, pfx,
            :any_stdout_path, _odfs,
            :any_stderr_path, _edfs,
            :result_code_x, _ec,
            * ft_a )
        end
      end
    end
  end
end
