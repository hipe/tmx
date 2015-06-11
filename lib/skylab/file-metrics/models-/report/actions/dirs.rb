module Skylab::FileMetrics

  class Models_::Report

    class Actions::Dirs < Report_Action_

      @is_promoted = true

      if false

      option_parser do |op|
        op.banner = <<-DESC.gsub(/^ +/, EMPTY_S_)
          #{ hi 'description:' }#{
          } Experimental report. With all folders one level under <path>,
          for each of them report number of files and total sloc,
          and show them in order of total sloc.
        DESC
        op_common_head
        op_common_tail
      end

      def dirs path=nil
        opts = @param_h
        opts[:path] = path || '.'
        api_call :dirs
      end

      # <-
    def run

      c = FM_::Models::Totaller.new("folders summary")

      dirs = build_find_dirs_command.to_path_stream.to_a

      if @req[:show_file_list] || @req.fetch( :debug_volume )
        @ui.err.puts( dirs )
      end
      dirs.each do |dir|
        cmd = build_find_files_command( [ dir ] ) or break
        st = stdout_line_stream_via_args cmd.args
        st or break

        # (for fun, leaving below antique lines intact as long as possible!)
        _dir_count = Models::Totaller.new(dir, nil)
        _ok_files = []; _errs = []

        begin
          f = st.gets
          f or break
          f.chomp!
          if File.exist?(f)
            if File.readable?(f)
              _ok_files.push(f)
            else
              _dir_count.add_child(Models::Totaller.new(f, nil, :notice => "not readable"))
            end
          else
            _dir_count.add_child(Models::Totaller.new(f, nil, :notice => "bad link"))
          end
          redo
        end while nil

        o = Report_::Sessions_::Line_Count.new
        o.count_blank_lines = h[ :count_blank_lines ]
        o.count_comment_lines = h[ :count_comment_lines ]
        o.file_array = _ok.files
        o.label = ::File.basename dir
        o.on_event_selectively = @on_event_selectively

        folder_count = o.execute
        folder_count.count ||= 0
        c.add_child folder_count
      end
      if c.zero_children?
        @ui.err.puts "(no dirs)"
        nil
      else
        c.collapse_and_distribute do |cx|
          cx.set_field :num_files, cx.nonzero_children?  # ick / meh
          cx.set_field :num_lines, cx.count  # just to be clear
        end
      end
      render_table c, @ui.err
    end

    # (we are trying to keep some ancient code for posterity for now ..)
    module Models
      Totaller = FM_::Models::Totaller.subclass(
        :num_files,
        :num_lines,
        :total_share,
        :normal_share )
    end

    LineCount = Models::Totaller

  private

    def build_find_dirs_command
      FM_.lib_.system.filesystem.find(
        :path, @req[ :path ],
        :ignore_dirs, @req[ :exclude_dirs ],
        :filenames, @req[ :include_names ],
        :freeform_query_infix_words, %w'-a -maxdepth 1 -type d',
        :as_normal_value, IDENTITY_
      ) do | i, *_, & ev_p |
        if :info == i
          if @req[ :show_commands ]
            _ev = p[]
            @ui.err.puts _ev.command_string
          end
        else
          raise ev.to_exception
        end
      end
    end

      end  # if false
      # <-
    end
  end
end
