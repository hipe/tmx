module Skylab::GitViz::TestSupport::VCS_Adapters::Git

  module Story_01

    class Actors_::Normalize_command

      def initialize nm, td, s, io
        @main_mock_repo_path = s
        @name_mappings = nm
        @serr = io
        @tmpdir = td
        freeze
      end

      def against cmd
        dup.__against cmd
      end

      protected def __against cmd
        @cmd = cmd
        @category_symbol = cmd.argv.fetch( 1 ).gsub( DASH_, UNDERSCORE_ ).intern
        send :"__normalize__#{ @category_symbol }__command"
        @cmd  # all failure is excepional
      end

      def __normalize__ls_files__command

        _do_the_chdir_line
        NIL_
      end

      def __normalize__log__command

        send "__normalize_git_log_command_for_argv_length__#{ @cmd.argv.length }__"
      end

      def __normalize_git_log_command_for_argv_length__5__  # ICK

        a = @cmd.argv
        src, dst = RANGE_RX___.match( a.fetch 3 ).captures
        a[ 3 ] = "#{ _convert_short src }..#{ _convert_short dst }"

        _mutate_string_by_converting_each_line_content @cmd.stdout_string do | line |
          _convert_long line
        end

        _do_the_chdir_line
        NIL_
      end

      short_sha = '[0-9a-z]{7}'

      sha = '[0-9a-z]{38,42}'  #todo

      RANGE_RX___ = /\A(#{ short_sha })\.\.(#{ short_sha })\z/

      def __normalize_git_log_command_for_argv_length__7__  # ICK

        _mutate_string_by_converting_each_line_content @cmd.stdout_string do | line |
          _convert_long line
        end

        _do_the_chdir_line
        NIL_
      end

      def __normalize__cherry__command

        a = @cmd.argv
        a[ -1 ] = _convert_short a[ -1 ]
        a[ -2 ] = _convert_short a[ -2 ]

        if @cmd.stdout_string.length.nonzero?
          require 'byebug' ; byebug ; $stderr.puts( "FML" ) && nil
        end

        _do_the_chdir_line
        NIL_
      end

      def __normalize__show__command

        __do_the_last_ARGV_term
        __do_the_SHA_line
        __do_the_datetime_line
        _do_the_chdir_line

        NIL_
      end

      def __do_the_last_ARGV_term

        nm = @name_mappings
        sha_x = @cmd.argv.fetch( -2 )

        if SHA_LIKE_RX___ =~ sha_x

          if 37 < sha_x.length

            _moniker = nm.commit_moniker_via_SHA_head_h.fetch sha_x[ 0, SHORT_SHA_LENGTH_ ]
            use_SHA = nm.long_mock_SHA_via_normal_ordinal _moniker
          else

            _moniker = nm.commit_moniker_via_SHA_head_h.fetch sha_x
            use_SHA = nm.short_mock_SHA_via_normal_ordinal _moniker
          end

          @cmd.argv[ -2 ] = use_SHA
        end

        NIL_
      end

      SHA_LIKE_RX___ = /\A[0-9a-f]+\z/

      def __do_the_SHA_line

        @moniker = nil

        nm = @name_mappings
        @cmd.stdout_string.sub! SHA_LIKE_FIRST_LINE_RX__ do

          @moniker = nm.commit_moniker_via_SHA_head_h.fetch(
            $~[ 0 ][ 0, SHORT_SHA_LENGTH_ ] )

          "#{ nm.long_mock_SHA_via_normal_ordinal @moniker }\n"
        end
        NIL_
      end

      SHA_LIKE_FIRST_LINE_RX__ = /\A#{ sha }\n(#{ sha }[[:space:]]$)?/  # #todo

      def __do_the_datetime_line

        @cmd.stdout_string.sub! DATETIME_SECOND_LINE_RX___ do

          d = @name_mappings.integer_via_normal_ordinal @moniker
          _ = TWO_FMT__ % d
          __  = TWO_FMT__ % ( d + 6 )
          ___ = TWO_FMT__ % ( d + 8 )

          "1999-01-#{ _ } 13:#{ __ }:#{ ___ } +0000"
        end
        NIL_
      end

      DATETIME_SECOND_LINE_RX___ = /(?<=\A.{40}\n)\d{4}-\d\d-\d\d \d\d:\d\d:\d\d [-+]\d{4}/

      TWO_FMT__ = '%02d'

      def _do_the_chdir_line

        s = @cmd.chdir

        if @tmpdir == s

          s.replace @main_mock_repo_path

        else

          # replace the real tmpdir part wih the mock repository path part

          s_ = "#{ @tmpdir }#{ ::File::SEPARATOR }"
          s_ == s[ 0, s_.length ] or fail

          s.replace ::File.join @main_mock_repo_path, s[ s_.length .. -1 ]
        end
        NIL_
      end

      def _mutate_string_by_converting_each_line_content screen

        st = GitViz_.lib_.basic::String.line_stream screen

        a = []
        begin
          line = st.gets
          line or break
          content, terminator = CONTENT_AND_TERMINATOR_RX___.match( line ).captures

          content.replace yield content

          a.push "#{ content }#{ terminator }"
          redo
        end while nil

        screen.replace a.join EMPTY_S_

        NIL_
      end

      CONTENT_AND_TERMINATOR_RX___ = /\A(|.*[^\r\n])(\r?\n)?\z/

      def _convert_long long_SHA

        @name_mappings.long_mock_SHA_via_normal_ordinal(
          _moniker_via_short long_SHA[ 0, SHORT_SHA_LENGTH_ ] )
      end

      def _convert_short short_SHA

        @name_mappings.short_mock_SHA_via_normal_ordinal(
          _moniker_via_short short_SHA )
      end

      def _moniker_via_short short_SHA

        @name_mappings.commit_moniker_via_SHA_head_h.fetch short_SHA
      end
    end
  end
end
