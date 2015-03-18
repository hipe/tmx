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

        a = []
        nm = @name_mappings
        st = GitViz_.lib_.basic::String.line_stream @cmd.stdout_string
        begin

          line = st.gets
          line or break

          sha, rest = SHA_AND_REST_RX___.match( line ).captures

          _moni = nm.commit_moniker_via_SHA_head_h.fetch(
            sha[ 0, SHORT_SHA_LENGTH__ ] )

          _sha_ = nm.long_mock_SHA_via_normal_ordinal _moni
          a.push "#{ _sha_ }#{ rest }"
          redo
        end while nil

        @cmd.stdout_string.replace a.join EMPTY_S_

        _do_the_chdir_line
        NIL_
      end

      sha = '[0-9a-z]{38,42}'  #todo

      SHA_AND_REST_RX___ = /(\A#{ sha })(.+)?\z/m

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

            _moniker = nm.commit_moniker_via_SHA_head_h.fetch sha_x[ 0, SHORT_SHA_LENGTH__ ]
            use_SHA = nm.long_mock_SHA_via_normal_ordinal _moniker
          else

            _moniker = nm.commit_moniker_via_SHA_head_h.fetch sha_x
            use_SHA = nm.short_mock_SHA_via_normal_ordinal _moniker
          end

          @cmd.argv[ -2 ] = use_SHA
        end

        NIL_
      end

      SHA_LIKE_RX___ = /\A[0-9a-z]+\z/

      def __do_the_SHA_line

        @moniker = nil

        nm = @name_mappings
        @cmd.stdout_string.sub! SHA_LIKE_FIRST_LINE_RX__ do

          @moniker = nm.commit_moniker_via_SHA_head_h.fetch(
            $~[ 0 ][ 0, SHORT_SHA_LENGTH__ ] )

          "#{ nm.long_mock_SHA_via_normal_ordinal @moniker }\n"
        end
        NIL_
      end

      SHA_LIKE_FIRST_LINE_RX__ = /\A#{ sha }\n(#{ sha }[[:space:]]$)?/  # #todo

      SHORT_SHA_LENGTH__ = 7

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
    end
  end
end
