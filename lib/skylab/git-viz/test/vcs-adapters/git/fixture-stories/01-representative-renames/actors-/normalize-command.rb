module Skylab::GitViz::TestSupport::VCS_Adapters::Git

  module Story_01

    class Actors_::Normalize_command

      def initialize nm, s, io
        @main_mock_repo_path = s
        @name_mappings = nm
        @serr = io
        freeze
      end

      def against cmd
        dup.__against cmd
      end

      protected def __against cmd
        @cmd = cmd
        execute
      end

      def execute

        if SHA_LIKE_FIRST_LINE_RX__ =~ @cmd.stdout_string

          __normalize_show_command
        else

          @serr.puts "applying default normalization to #{ @cmd.stderr_string.inspect }"

          _do_the_chdir_line
        end

        @cmd  # failure is excepional
      end

      def __normalize_show_command

        __do_the_last_ARGV_term
        __do_the_SHA_line
        __do_the_datetime_line
        _do_the_chdir_line

        NIL_
      end

      def __do_the_last_ARGV_term

        short_SHA = @cmd.argv.fetch( -2 )

        if HEAD___ != short_SHA

          _moniker = @name_mappings.commit_moniker_via_SHA_head_h.fetch short_SHA

          _short = @name_mappings.short_mock_SHA_via_normal_ordinal _moniker

          @cmd.argv[ -2 ] = _short
        end

        NIL_
      end

      HEAD___ = 'head'

      def __do_the_SHA_line

        @moniker = nil

        nm = @name_mappings
        @cmd.stdout_string.sub! SHA_LIKE_FIRST_LINE_RX__ do

          @moniker = nm.commit_moniker_via_SHA_head_h.fetch(
            $~[ 0 ][ 0, SHORT_SHA_LENGTH___ ] )

          nm.long_mock_SHA_via_normal_ordinal @moniker
        end
        NIL_
      end

      SHA_LIKE_FIRST_LINE_RX__ = /\A[a-z0-9]{38,42}$/  # #todo

      SHORT_SHA_LENGTH___ = 7

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
        @cmd.chdir.replace @main_mock_repo_path
        NIL_
      end
    end
  end
end
