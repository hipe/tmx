module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Commit_::Build__ < Git::System_Agent_

      def initialize repo, sha, listener, & sa_p
        @repo = repo ; @SHA = sha
        _cmd_s_a = [ GIT_EXE_,
          'show', '--numstat', '--pretty=tformat:%ai', @SHA.to_string, '--' ]
        super listener do |sa|
          sa.set_chdir_pathname @repo.absolute_pathname
          sa.set_cmd_s_a _cmd_s_a
          sa_p && sa_p[ sa ]
        end
      end

      def execute
        @scn = get_any_nonzero_count_output_line_scanner_from_cmd
        @scn and bld_ci_via_processing_each_line_of_the_show_screen
      end

    private

      def bld_ci_via_processing_each_line_of_the_show_screen
        @writable_ci = @repo.class::Commit_.new_writable @SHA
        ok = prcss_ISO_8601_datetime
        ok &&= prcss_file_lines
        ok and finish
      end

      def prcss_ISO_8601_datetime
        s = @scn.gets or self.sanity
        s_ = normalize_ISO_8601_string s
        s_ or fail "test me - ISO compliant string? - #{ s }"
        _dt = GitViz_._lib.date_time.iso8601 s_  # throes a.e, fine for now
        @writable_ci.set_author_datetime _dt
        PROCEDE_
      end

      def normalize_ISO_8601_string s  # [#009] #storypoint-10
        md = GIT_STYLE_ISO8601_RX__.match s
        if md
          _date, _time, _zone = md.captures
          "#{ _date }T#{ _time }#{ _zone }"
        end
      end
      GIT_STYLE_ISO8601_RX__ =
        /\A(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2}) ([-+]\d{4})\z/

      def prcss_file_lines
        empty = @scn.gets
        EMPTY_STRING__ == empty or raise say_expecting_blank line
        scan_a_nonzero_count_of_lines @scn.gets
      end ; EMPTY_STRING__ = ''.freeze

      def say_expecting_blank line
        "expected this second line of the show command to be blank, wasn't #{
          }(this is written assuming 'tformat' and not 'format'): #{
           }#{ line.inspect }"
      end

      def scan_a_nonzero_count_of_lines line_s  # #storypoint-20
        begin
          md = NUMSTAT_LINE_RX__.match line_s
          md or fail "rx sanity - #{ line_s.inspect }"
          @writable_ci.add_numstat_entry( * md.captures )
          line_s = @scn.gets
        end while line_s
        PROCEDE_
      end
      NUMSTAT_LINE_RX__ = /\A(\d+)\t(\d+)\t(.+)\z/

      def finish
        @writable_ci.finish_write
      end
    end
  end
end
