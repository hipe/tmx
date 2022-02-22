module Skylab::CodeMetrics

  module Home_::Model_::Support

    class Models_::Dirs < Report_Action

      edit_entity_class(

        :branch_description, -> y do
           y << "with each immediate child directory of <path>"
           y << "report its number of files and total SLOC,"
           y << "and display them in descending order of SLOC."
        end,

        :reuse, COMMON_PROPERTIES.at(
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

        totes = @_totes_class.new
        totes.slug = "folders summary"
        @_totes = totes

        ok = ACHIEVED_
        @_dirs.each do | dir |
          ok = __visit_dir dir
          ok or break
        end
        if ok
          ___finish
          @_totes
        end
        ok
      end

      def ___finish

        @_totes.finish_by do | cx |
          cx.num_files = cx.children_count
          cx.num_lines = cx.count  # redundant, but more clear
        end
        NIL_
      end

      Totaller_class___ = Common_.memoize do

        Totaller____ = Totaller_[].new(
          :num_files,
          :num_lines,
        )
      end

      def __visit_dir dir
        y = __produce_dir_files dir
        y and __visit_dir_via_files y, dir
      end

      def __visit_dir_via_files y, dir

        h = @argument_box.h_

        o = Home_::Magnetics_::LineCount_via_Arguments.new
        o.count_blank_lines = ! h[ :without_blank_lines ]
        o.count_comment_lines = ! h[ :without_comment_lines ]
        o.file_array = y
        o.label = ::File.basename dir
        o.listener = @listener
        o.system_conduit = system_conduit_
        o.totaller_class = @_totes_class

        totes = o.execute

        if totes
          if ! totes.count
            self._SANITY  # there's that one gotcha when one line from wc
          end
          @_totes.append_child_ totes
          @_totes
        else
          totes
        end
      end

      def __produce_dir_files dir

        cmd = build_find_files_command_via_paths_ [ dir ]

        if cmd

          st = line_upstream_via_system_command_ cmd.args
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
        if ok
          Home_.lib_.system.maybe_sort_filesystem_paths y  # #history-B.1
        else
          ok
        end
      end

      def __resolve_dirs

        _ok = __resolve_find_dirs_command
        _ok && __via_find_dirs_command_resolve_dirs
      end

      def __via_find_dirs_command_resolve_dirs

        _, o, e, w = system_conduit_.popen3( * @_find_dirs_command.args )

        y = Home_::ThroughputAdapters_::SynchronousRead.call(
          [], nil, o, e, w, & @listener )

        if y
          @_dirs = y

          @listener.call :info, :data, :file_list do
            @_dirs
          end

          ACHIEVED_
        else
          y
        end
      end

      def __resolve_find_dirs_command

        h = @argument_box.h_

        cmd = Home_.lib_.system.find(
          :path, h.fetch( :path ),
          :ignore_dirs, h.fetch( :exclude_dir ),
          :filenames, h[ :include_name ],
          :freeform_query_infix_words, %w'-a -maxdepth 1 -type d',
          :when_command, IDENTITY_ )

        if cmd

          @listener.call :info, :find_dirs_command do
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
# #history-B.1: target Ubuntu not OS X
