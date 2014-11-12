module Skylab::BeautySalon

  class Models_::Search_and_Replace

    class Actors_::Build_grep_path_scan

      Callback_::Actor.call self, :properties,

        :upstream_path_scan,
        :ruby_regexp,
        :mode,
        :chunk_size,
        :on_event_selectively

      def initialize
        super
        @chunk_size ||= 50  # meh etc
        @shellwords = BS_::Lib_::Shellwords[]
      end

      def execute
        @command = BS_::Lib_::System[].filesystem.grep(
          :ruby_regexp, @ruby_regexp,
          :on_event_selectively, -> * i_a, & ev_p do
            @on_event_selectively[ * i_a, & ev_p ]
            UNABLE_
          end )
        @command and via_command
      end

      def via_command
        send :"init_command_head_for_#{ @mode }"

        @on_event_selectively.call :info, :grep_command_head do
          BS_::Lib_::Event_lib[].inline_neutral_with :grep_command_head,
            :command_head, @head_s
        end

        send :"via_command_head_when_#{ @mode }"
      end

      def init_command_head_for_counts
        @head_s = "#{ @command.string } --count ".freeze
      end

      def init_command_head_for_paths
         @head_s = "#{ @command.string } --files-with-matches ".freeze
      end

      def via_command_head_when_counts
        via_command_head_when_paths.map_reduce_by do |path|
          md = COUNT_LINE_RX__.match path
          if md
            d = md[ 2 ].to_i
            if d.nonzero?
              Count_Item__.new md[ 1 ], md[ 2 ].to_i
            end
          else
            @on_event_selectively.call :error_string do
              "failed to match: #{ path }"
            end
            nil
          end
        end
      end

      COUNT_LINE_RX__ = /\A(.+):(\d+)\z/

      Count_Item__ = ::Struct.new :path, :count

      def via_command_head_when_paths
        p = -> do
          scn = produce_next_scan
          p = -> do
            while scn
              x = scn.gets
              x and break
              scn = produce_next_scan
            end
            x
          end
          p[]
        end
        Callback_.scan do
          p[]
        end
      end

      def produce_next_scan
        a = take_nonzero_length_escaped_paths_chunk
        if a
          _command_s = "#{ @head_s }#{ a * SPACE_ }"
          @command.produce_scan_via_command_string _command_s
        end
      end

      def take_nonzero_length_escaped_paths_chunk
        path = @upstream_path_scan.gets
        if path
          y = [ @shellwords.escape( path ) ]
          d = 1 ; max = @chunk_size
          while d < max
            d += 1
            path = @upstream_path_scan.gets
            path or break
            y.push @shellwords.escape path
          end
          y
        end
      end
    end
  end
end
