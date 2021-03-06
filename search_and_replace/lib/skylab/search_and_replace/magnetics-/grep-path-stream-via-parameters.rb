module Skylab::SearchAndReplace

  class Magnetics_::Grep_Path_Stream_via_Parameters

    def initialize & p

      @chunk_size = 50  # ..
      @grep_extended_regexp_string = nil
      @ruby_regexp = nil
      @_shellwords = Home_.lib_.shellwords

      @_listener = p
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

      @_listener.call :info, :expression, :grep_command_head do |y|

        # (see tombstone for the beginnings of a structured event)

        y << "grep command head: #{ _command_string.inspect }"
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
            Count_Item___.new md[ 1 ], d
          end
        else
          # (not covered)
          @_listener.call :error, :expression, :counts_by_grep do |y|
            y << "failed to match line from grep: #{ path.inspect }"
          end
          NIL_
        end
        # -
      end
    end

    COUNT_LINE_RX___ = /\A(.+):(\d+)\z/

    class Count_Item___

      def initialize path, count_d
        @count = count_d
        @path = path
      end

      def express_into_under y, expag

        d = @count
        path = @path
        expag.calculate do
          y << "#{ pth path } - #{ d } matching #{ plural_noun d, 'line' }"  # "N matches"
        end
      end

      attr_reader(
        :count,
        :path,
      )
    end

    def _to_grep_result_path_stream

      st = nil

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

      Common_::Stream.define do |o|
        o.upstream_as_resource_releaser_by do
          if st
            st.upstream.release_resource
          else
            ACHIEVED_
          end
        end
        o.stream_by do
          p[]
        end
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

      _gr = Home_.lib_.system.grep(
        :grep_extended_regexp_string, @grep_extended_regexp_string,
        :ruby_regexp, @ruby_regexp,
        :freeform_options, a,
        & @_listener )

      __store_trueish :@_grep_command, _gr
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

    define_method :__store_trueish, METHOD_DEFINITION_FOR_STORE_TRUEISH_
  end
end
# #tombstone: grep command head as inline event
