# frozen_string_literal: true

module Skylab::Git

  module Magnetics::BlameLineStream_via_Path

    # #coverpoint1.1 - do a `git blame` and structure its line results

    class << self
      def statisticator_by ** h
        Statisticator___.new( ** h )
      end
    end  # >>

    # ==

    class Statisticator___

      def initialize(
        path: nil,
        piper: nil,
        spawner: nil,
        waiter: nil,
        listener: nil
      )
        _System = Home_.lib_.system_lib
        _cmd_s_a = __build_the_whole_command path

        @_getser = _System::Command::Processer.getser_by(
          command_string_array: _cmd_s_a,
          piper: piper,
          spawner: spawner,
          waiter: waiter,
          listener: listener,
        )

        Home_.lib_.string_scanner  # for use #here1

        @__commit_pool = Home_::Models::Commit::StatistitcatingPool.new

        @_paths = {}
      end

      def gets_one_git_blame_line
        line = @_getser.gets_one_stdout_line
        if line
          GitBlameLine___.new line, self
        end
      end

      def was_OK
        @_getser.was_OK
      end

      def nonzero_exitstatus
        @_getser.nonzero_exitstatus
      end

      def __build_the_whole_command path
        cmd = [ GIT_EXE_ ]
        cmd << 'blame'
        cmd << path
        cmd
      end
    end  # #re-opens

    # ==

    class GitBlameLine___

      def initialize line, cx
        @_caches = cx
        @_scn = ::StringScanner.new line  #here1
        __parse_SHA
        _skip_space
        __maybe_parse_path
        _skip %r(\()
        __parse_author
        _skip_space
        __parse_date_time
        _skip_multiple_spaces
        __parse_line_number
        _skip %r(\) )
        @line = remove_instance_variable( :@_scn ).rest.freeze
        remove_instance_variable :@_caches
        freeze
      end

      # --

      def __parse_date_time

        _s = _scan %r(\d{4}-\d{2}-\d{2}   [ ]  \d{2}:\d{2}:\d{2}  [ ]  [+-]\d+)x

        @commit = @_caches.commit_via_three(
          remove_instance_variable( :@__sha ),
          _s,
          remove_instance_variable( :@__author_name ),
        )
        NIL
      end

      def __parse_line_number
        _d_s = _scan %r(\d+)
        @lineno = _d_s.to_i ; nil
      end

      def __parse_author
        s = _scan %r( (?: (?![ ]\d{4}). ) + )x
        s.strip!  # meh
        @__author_name = s ; nil
      end

      def __maybe_parse_path
        if @_scn.peek( 1 ) == '('
          # (then this file has no renames, probably #cover-me)
          @path = nil
        else
          __parse_path
          _skip_multiple_spaces
        end
      end

      def __parse_path
        _path = _scan %r([^ ]+)
        @path = @_caches.path_via_path _path ; nil
      end

      def __parse_SHA
        _parse :@__sha, %r([0-9a-f]{7,9}) ; nil
      end

      # --

      def _parse ivar, rx
        _s = _scan rx
        instance_variable_set ivar, _s.freeze ; nil
      end

      def _scan rx
        s = @_scn.scan rx
        if s
          s
        else
          ::Kernel._OKAY
        end
      end

      def _skip_multiple_spaces
        _skip %r([ ]+)
      end

      def _skip_space
        _skip %r([ ])
      end

      def _skip rx
        d = @_scn.skip rx
        if ! d
          ::Kernel._OKAY
        end
      end

      # --

      attr_reader(
        :commit,
        :lineno,
        :line,
        :path,
      )
    end

    # ==

    class Statisticator___  # #re-open

      def commit_via_three * three
        @__commit_pool.commit_via_three( * three )
      end

      def path_via_path freezable_s
        _same :@_paths, freezable_s
      end

      def _same ivar, freezable_s
        _same_by ivar, freezable_s do
          freezable_s.freeze
        end
      end

      def _same_by ivar, s
        h = instance_variable_get ivar
        h.fetch s do
          x = yield
          h[ s ] = x
          x
        end
      end
    end

    # ==

    # ==
    # ==
  end
end
# #born.
