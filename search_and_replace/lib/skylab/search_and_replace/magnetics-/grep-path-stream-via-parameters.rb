module Skylab::SearchAndReplace

  class Magnetics_::Grep_Path_Stream_via_Parameters

    def initialize & oes_p

      @chunk_size = 50  # ..
      @grep_extended_regexp_string = nil
      @ruby_regexp = nil
      @_shellwords = Home_.lib_.shellwords

      @_oes_p = oes_p
    end

    attr_writer(
      :chunk_size,
      :for,  # { counts | paths }
      :grep_extended_regexp_string,
      :ruby_regexp,
      :upstream_path_stream,
    )

    def execute

      _ok = __resolve_grep_command
      _ok && ___via_grep_command
    end

    # --

    def ___via_grep_command

      gr = remove_instance_variable :@_grep_command

      cmd = gr.to_command
      _command_string = cmd.command_string

      @_oes_p.call :info, :grep_command_head do

        Callback_::Event.inline_neutral_with(
          :grep_command_head,
          :command_head, _command_string,
        )
      end

      @_grep_runner = gr
      @_grep_command_without_paths = cmd

      send :"__when__#{ @for }__"
    end

    def __when__counts__

      _st = _to_grep_result_path_stream
      _st.map_reduce_by do |path|

        md = COUNT_LINE_RX___.match path
        if md
          d = md[ 2 ].to_i
          if d.nonzero?
            Count_Item___.new md[ 1 ], md[ 2 ].to_i
          end
        else
          # (not covered)
          @_oes_p.call :error, :expression, :counts_by_grep do |y|
            y << "failed to match line from grep: #{ path.inspect }"
          end
          NIL_
        end
        # -
      end
    end

    COUNT_LINE_RX___ = /\A(.+):(\d+)\z/
    Count_Item___ = ::Struct.new :path, :count

    def _to_grep_result_path_stream

      st = nil
      _Stream = Callback_::Stream

      _resource_releaser = _Stream::Resource_Releaser.new do
        if st
          st.upstream.release_resource
        else
          ACHIEVED_
        end
      end

      main_p = -> do
        while st
          x = st.gets
          x and break
          st = _next_stream
        end
        x
      end

      p = -> do
        st = _next_stream
        p = main_p
        p[]
      end

      _Stream.new _resource_releaser do
        p[]
      end
    end

    alias_method(  # we both call it internally and expose it
      :__when__paths__,
      :_to_grep_result_path_stream,
    )

    def _next_stream

      open_cmd = @_grep_command_without_paths.open

      _did = ___write_more_than_one_path_into open_cmd

      if _did

        _cmd = open_cmd.close
        @_grep_runner.line_content_stream_via_command _cmd
      end
    end

    def ___write_more_than_one_path_into cmd

      path = @upstream_path_stream.gets
      if path

        d = 1 ; max = @chunk_size
        begin
          cmd.push_item path

          if d >= max
            break
          end

          path = @upstream_path_stream.gets
          path or break
          d += 1

          redo
        end while nil

        ACHIEVED_
      end
    end

    # --

    def __resolve_grep_command

      a = []

      send :"__write_grep_options_for__#{ @for }__", a

      gr = Home_.lib_.system.filesystem.grep(
        :grep_extended_regexp_string, @grep_extended_regexp_string,
        :ruby_regexp, @ruby_regexp,
        :freeform_options, a,
        & @_oes_p )

      if gr
        @_grep_command = gr
        ACHIEVED_
      else
        gr
      end
    end

    def __write_grep_options_for__counts__ a

      # the '-H' option is crucial to avoid a SPURIOUS "bug" that happens
      # otherwise: one out of (say) 50 times, if you have only filename, the
      # file header won't be displayed and our parse will break.

      a.push COUNT_OPTION___, H_OPTION___ ; nil
    end

    COUNT_OPTION___ = '--count'.freeze

    H_OPTION___ = '-H'.freeze

    def __write_grep_options_for__paths__ a

      a.push FILES_WITH_MATCHES_OPTION___ ; nil
    end

    FILES_WITH_MATCHES_OPTION___ = '--files-with-matches'.freeze
  end
end
