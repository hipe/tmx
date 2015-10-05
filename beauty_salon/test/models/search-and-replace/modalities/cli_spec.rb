require_relative '../../../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] search and replace - interactive" do

    extend TS_
    use :expect_interactive  # [br]
    use :models_search_and_replace  # defines hook-outs for above

    context "counts" do

      _COMMON_FIELD_PROMPT_ENDING = ' (nothing to cancel): '
      _COMMON_BRANCH_PROMPT_ENDING = ' [q]uit: '

      # the following two lines are used by a test in this file:
      # hinkenlooper
      # hinkenlooper

      it "testing interactivity is possble but cumbersome .." do

        # NOTE the directory from which we execute this is not the same
        # as the directory against which we are searching. the former is
        # a volatile, mutable directory that needs to be able to hold the
        # persisted session data. the latter is a parent directory of this
        # file!

        td = memoized_tmpdir_.tmpdir_via_join 'started-out-empty'
        td.prepare
        _path = td.to_path
        td = nil
        _near_here = TS_::Models::Search_And_Replace.dir_pathname.to_path

        t = ::Time.now

        start_interactive_session _path

        expect_screen_ending_with _COMMON_BRANCH_PROMPT_ENDING

        _enter_field_selector 'search'

        @interactive_session.puts '\bhinkenlooper\b'  # hackishly we assert that the file is written

        _in_lines do | lines |

          lines.advance_one
          string = lines.gets_one
          string.encode! ::Encoding::UTF_8, ::Encoding::UTF_8
          string.should match %r(\Acreating «[^»]+» \.\. done\.$)
        end

        _enter_field 'dirs', _near_here

        _enter_field 'files', '*.rb'

        _enter_navigation_step 'preview'
        _in_screen do
          expect_string %r(^[ ]+matches[ ])
        end

        _enter_navigation_step 'matches'
        _in_screen do
          expect_string %r(^[ ]+ruby[ ])
        end

        _push_button 'grep'
        _in_screen do
          expect_string %r(^[ ]+grep[ ]+ON\b)
        end

        _push_button 'counts'
        flush_to_lines_screen_ending_with _COMMON_BRANCH_PROMPT_ENDING
        @interactive_session.close

        after_any_blanks_expect_line %r(\A\(grep command head: grep -E )
        after_any_blanks_expect_line "#{ ::File.expand_path( __FILE__ ) }:2\n"
        after_any_blanks_expect_line "(2 matches in 1 file)\n"

        expect_blank_line
        expect_several_more_lines

        t = ::Time.now - t
        $stderr.puts "(that cumbersome single test took #{ t } seconds.)"
      end

      def _enter_navigation_step s
        @interactive_session.puts s
      end

      def _push_button s
        @interactive_session.puts s
      end

      define_method :_in_lines do | & p |
        in_lines_of_screen_ending_with _COMMON_BRANCH_PROMPT_ENDING, & p
      end

      define_method :_in_screen do | & p |
        in_screen_ending_with _COMMON_BRANCH_PROMPT_ENDING, & p
      end

      def _enter_field name, value
        _enter_field_selector name
        _enter_field_value value
        nil
      end

      define_method :_enter_field_selector do |name|
        @interactive_session.puts name
        expect_screen_ending_with _COMMON_FIELD_PROMPT_ENDING
        nil
      end

      define_method :_enter_field_value do |value|
        @interactive_session.puts value
        expect_screen_ending_with _COMMON_BRANCH_PROMPT_ENDING
        nil
      end
    end
  end
end
