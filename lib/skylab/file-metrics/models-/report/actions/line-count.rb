module Skylab::FileMetrics

  class Models_::Report

    class Actions::Line_Count < Report_Action_

      @is_promoted = true

      o = COMMON_PROPERTIES_.method :fetch

      Entity_.call self,

        :desc, -> y do
          y << "Shows the linecount of each file, longest first."
          y << "Show percentages of max for each file."
        end,

        # aliases :lc, :sloc  # :+[#br-095]

        :description, -> y do
          y << "whether to count a line that looks like a shell-style comment"
        end,
        :flag,
        :default, false,
        :property, :without_comment_lines,

        :description, -> y do
          y << "whether to count blank lines"
        end,
        :flag,
        :default, false,
        :property, :without_blank_lines,

        :property_object, o[ :exclude_dir ],

        :property_object, o[ :include_name ],

        :property_object, o[ :show_report ],

        :argument_arity, :one_or_more,
        :parameter_arity, :one,
        :property, :path

      def produce_result

        _ok = __resolve_file_array
        _ok && __via_file_array
      end

      def __via_file_array

        @on_event_selectively.call :info, :data, :file_list do
          @file_array_
        end

        if @argument_box[ :show_report ]
          __work
        else
          ACHIEVED_
        end
      end

      def __work

        h = @argument_box.h_

        o = Report_::Sessions_::Line_Count.new

        o.count_blank_lines = ! h[ :without_blank_lines ]
        o.count_comment_lines = ! h[ :without_comment_lines ]
        o.file_array = @file_array_
        o.label = '.'
        o.on_event_selectively = @on_event_selectively
        o.system_conduit = system_conduit_
        o.totaller_class = Totaller_class___[]
        o.execute
      end

      Totaller_class___ = Callback_.memoize do

        Totaller____ = FM_::Models_::Totaller.subclass(
          :total_share,
          :normal_share )
      end

      def __resolve_file_array

        @_fs = filesystem_conduit_
        y = []

        @argument_box.fetch( :path ).each do | path |

          stat, e = __stat_and_exception path

          if stat
            if stat.file?
              y << path
            elsif stat.directory?
              __recurse y, path
            else
              self._COVER_ME
            end
          else
            __maybe_send_event_about_noent e
          end
        end

        remove_instance_variable :@_fs

        if y.length.zero?
          NIL_
        else
          @file_array_ = y
          ACHIEVED_
        end
      end

      def __stat_and_exception path

        stat = begin  # :+[#sy-021]
          e = nil
          @_fs.stat path
        rescue ::Errno::ENOENT => e
          false
        end
        [ stat, e ]
      end

      def __maybe_send_event_about_noent e

        @on_event_selectively.call :info, :enoent do

          Callback_::Event.wrap.exception.with(
            :exception, e,
            :path_hack,
            :terminal_channel_i, :enoent )
        end
        NIL_
      end

      def __recurse y, path

        cmd = build_find_files_command_via_paths_ [ path ]
        if cmd
          __recurse_via_command y, cmd
        else
          cmd
        end
      end

      def __recurse_via_command y, cmd

        @on_event_selectively.call :info, :command do  # ancitipating an active front
          cmd.to_event
        end

        _sin, sout, serr, wait = system_conduit_.popen3( * cmd.args )

        d = y.length

        ok = Report_::Sessions_::Synchronous_Read.call(
          y, nil, sout, serr, wait

        ) do  | * i_a, & ev_p |
          if :done == i_a.last
            # skip
          else
            self._DO_ME  # needs visual testing
          end
        end

        if ok
          if d == y.length
            self._SQUAK_AND_COVER_ME
          end
          ok
        else
          ok
        end
      end
    end
  end
end
