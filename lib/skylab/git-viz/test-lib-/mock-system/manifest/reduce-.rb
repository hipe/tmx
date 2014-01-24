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
          @mani = @IO_cache.retrieve_or_init Manifest::Handle, @pn, -> mani do
              @y << "(using cached manifest parse tree)" ; mani
            end, -> new do
              @y << "parsed #{ new.manifest_summary } in #{ @pn }" ; new
            end
          @mani ? PROCEDE_ : GENERAL_ERROR_
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
              cmd.parse_everything_as_necessary
              prefix = any_prefix cmd
              prefix or next
              add_result_item cmd, prefix
            end while(( cmd = scn.gets ))
          end
          issue_a_notice_if_no_items_were_added
          PROCEDE_
        end

        def command_string_does_pass_white_or_black_filters cmd_s
          _rx_that_it_did_not_match = @cmd_wht_rx_a.detect do |rx|
            rx !~ cmd_s
          end
          ! _rx_that_it_did_not_match
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
