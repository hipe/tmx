module Skylab::SearchAndReplace

  class Magnetics_::Grep_Path_Stream_via_Parameters

    def initialize & pp

      @chunk_size = 50  # ..
      @grep_extended_regexp_string = nil
      @ruby_regexp = nil
      @shellwords = Home_.lib_.shellwords

      @_pp = pp
    end

    attr_writer(
      :chunk_size,
      :for,  # { counts | paths }
      :grep_extended_regexp_string,
      :ruby_regexp,
      :upstream_path_stream,
    )

    def execute

      @_oes_p = @_pp[ nil ]

      cmd = Home_.lib_.system.filesystem.grep(
        :grep_extended_regexp_string, @grep_extended_regexp_string,
        :ruby_regexp, @ruby_regexp,
        & @_oes_p )

      if cmd
        @_command = cmd
        ___via_command
      else
        cmd
      end
    end

    def ___via_command

      send :"__init_command_head_for__#{ @for }__"

      @_oes_p.call :info, :grep_command_head do

        _ = Callback_::Event.inline_neutral_with(
          :grep_command_head,
          :command_head, @_head_s,
        )
        _
      end

      send :"__via_command_head_when__#{ @for }__"
    end

    def __init_command_head_for__counts__
      @_head_s = "#{ @_command.string } --count ".freeze
    end

    def __init_command_head_for__paths__
      @_head_s = "#{ @_command.string } --files-with-matches ".freeze
    end

    def __via_command_head_when__counts__

      __via_command_head_when_paths.map_reduce_by do |path|
        md = COUNT_LINE_RX___.match path
        # -
          if md
            d = md[ 2 ].to_i
            if d.nonzero?
            Count_Item___.new md[ 1 ], md[ 2 ].to_i
            end
          else
            @on_event_selectively.call :error_string do
              "failed to match: #{ path }"
            end
            nil
          end
        # -
      end
    end

    COUNT_LINE_RX___ = /\A(.+):(\d+)\z/

    Count_Item___ = ::Struct.new :path, :count

    def __via_command_head_when__paths__
      # -
        st = nil
        p = -> do
          st = produce_next_stream
          p = -> do
            while st
              x = st.gets
              x and break
              st = produce_next_stream
            end
            x
          end
          p[]
        end

      # -

      _Stream = Callback_::Stream

      _releaser = _Stream::Resource_Releaser.new do
        if st
          st.upstream.release_resource
        else
          ACHIEVED_
        end
      end

      _Stream.new _releaser do
        p[]
      end
    end

    alias_method :__via_command_head_when_paths, :__via_command_head_when__paths__
    # -
      def produce_next_stream
        a = take_nonzero_length_escaped_paths_chunk
        if a
          _command_s = "#{ @_head_s }#{ a * SPACE_ }"
          @_command.produce_stream_via_command_string _command_s
        end
      end

      def take_nonzero_length_escaped_paths_chunk
        path = @upstream_path_stream.gets
        if path
          y = [ @shellwords.escape( path ) ]
          d = 1 ; max = @chunk_size
          while d < max
            d += 1
            path = @upstream_path_stream.gets
            path or break
            y.push @shellwords.escape path
          end
          y
        end
      end
    # -
  end
end
