module Skylab::FileMetrics

  class Models_::Report

    class Actions::Dirs < Report_Action_

      @is_promoted = true

      edit_entity_class(

        :desc, -> y do
           y << "with each immediate child directory of <path>"
           y << "report its number of files and total SLOC,"
           y << "and display them in descending order of SLOC."
        end,

        :reuse, COMMON_PROPERTIES_.at(
          :exclude_dir,
          :include_name
        ),

        :parameter_arity, :one,
        :property, :path
      )

      def produce_result

        _ok = __resolve_dirs
        _ok && __via_dirs
      end

      def __via_dirs

        @_totes_class = Totaller_class___[]

        @_totes = @_totes_class.new "folders summary"

        ok = ACHIEVED_
        @_dirs.each do | dir |
          ok = __visit_dir dir
          ok or break
        end
        ok && __synthesize
      end

      Totaller_class___ = Callback_.memoize do

        Totaller____ = FM_::Models_::Totaller.subclass(
          :num_files,
          :num_lines,
          :total_share,
          :normal_share )
      end

      def __synthesize

        @_totes.mutate_by_visit_then_sort do | cx |

          cx.set_field :num_files, cx.nonzero_children?  # ick / meh
          cx.set_field :num_lines, cx.count  # just to be clear
        end
        @_totes
      end

      def __visit_dir dir

        y = __produce_dir_files dir
        y and __visit_dir_via_files y, dir
      end

      def __visit_dir_via_files y, dir

        h = @argument_box.h_

        o = Report_::Sessions_::Line_Count.new
        o.count_blank_lines = ! h[ :without_blank_lines ]
        o.count_comment_lines = ! h[ :without_comment_lines ]
        o.file_array = y
        o.label = ::File.basename dir
        o.on_event_selectively = @on_event_selectively
        o.system_conduit = system_conduit_
        o.totaller_class = @_totes_class

        totes = o.execute
        if totes
          totes.count or self._WHEN
          @_totes.add_child totes
          ACHIEVED_
        else
          totes
        end
      end

      def __produce_dir_files dir

        cmd = build_find_files_command_via_paths_ [ dir ]

        if cmd

          st = stdout_line_stream_via_args_ cmd.args
          if st

            __produce_dir_files_via_path_stream st, dir
          else
            st
          end
        else
          cmd
        end
      end

      def __produce_dir_files_via_path_stream st, dir

        # #todo - consdier adding a mapper to the other

        ok = ACHIEVED_
        y = []
        begin
          s = st.gets
          s or break
          s.chomp!

          stat, e = stat_and_exception_ s
          if stat
            if stat.file? || stat.directory?
              y << s
            else
              self._SQUAWK
            end
          else
            maybe_send_event_about_noent_ e
            ok = UNABLE_
            break
          end
          redo
        end while nil
        ok && y
      end

      def __resolve_dirs

        _ok = __resolve_find_dirs_command
        _ok && __via_find_dirs_command_resolve_dirs
      end

      def __via_find_dirs_command_resolve_dirs

        _, o, e, w = system_conduit_.popen3( * @_find_dirs_command.args )

        y = Report_::Sessions_::Synchronous_Read[
          [], nil, o, e, w, & @on_event_selectively ]

        if y
          @_dirs = y

          @on_event_selectively.call :info, :data, :file_list do
            @_dirs
          end

          ACHIEVED_
        else
          y
        end
      end

      def __resolve_find_dirs_command

        h = @argument_box.h_

        cmd = FM_.lib_.system.filesystem.find(

          :path, h.fetch( :path ),
          :ignore_dirs, h.fetch( :exclude_dir ),
          :filenames, h[ :include_name ],
          :freeform_query_infix_words, %w'-a -maxdepth 1 -type d',
          :as_normal_value, IDENTITY_ )

        if cmd

          @on_event_selectively.call :info, :find_dirs_command do
            cmd.to_event
          end

          @_find_dirs_command = cmd
          ACHIEVED_
        else
          cmd
        end
      end
    end
  end
end
