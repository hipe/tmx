require_relative 'test-support'

module Skylab::BeautySalon::TestSupport::Models::Search_and_Replace

  describe "[bs] search and replace - interactive" do

    BS_.lib_.brazen.test_support::Zerk::Expect_Interactive[ self ]

    extend TS_

    context "counts" do

      _COMMON_FIELD_PROMPT_ENDING = ' (nothing to cancel): '
      _COMMON_BRANCH_PROMPT_ENDING = ' [q]uit: '

      # the following two lines are used by a test in this file:
      # hinkenlooper
      # hinkenlooper

      it "testing interactivity is possble but cumbersome" do
        t = ::Time.now

        start_interactive_session existent_empty_tmpdir_path

        expect_screen_ending_with _COMMON_BRANCH_PROMPT_ENDING

        enter_field_selector 'search'

        @session.puts '\bhinkenlooper\b'  # hackishly we assert that the file is written
        in_lines do |lines|
          lines.advance_one
          string = lines.gets_one
          rx = %r(\Acreating 束[^損]+損 \.\. done\.$)  # how do we match « » :+#guillemets ?
          require 'kconv'
          string.toutf8.should match rx
        end

        enter_field 'dirs', TS_.dir_pathname.to_path

        enter_field 'files', '*.rb'

        enter_navigation_step 'preview'
        in_screen do
          expect_string %r(^[ ]+matches[ ])
        end

        enter_navigation_step 'matches'
        in_screen do
          expect_string %r(^[ ]+ruby[ ])
        end

        push_button 'grep'
        in_screen do
          expect_string %r(^[ ]+grep[ ]+ON\b)
        end

        push_button 'counts'
        flush_to_lines_screen_ending_with _COMMON_BRANCH_PROMPT_ENDING
        @session.close

        after_any_blanks_expect_line %r(\A\(grep command head: grep -E )
        after_any_blanks_expect_line "#{ ::File.expand_path( __FILE__ ) }:2\n"
        after_any_blanks_expect_line "(2 matches in 1 file)\n"

        expect_blank_line
        expect_several_more_lines

        t = ::Time.now - t
        $stderr.puts "(that cumbersome single test took #{ t } seconds.)"
      end

      def enter_navigation_step s
        @session.puts s
      end

      def push_button s
        @session.puts s
      end

      define_method :in_lines do | & p |
        in_lines_of_screen_ending_with _COMMON_BRANCH_PROMPT_ENDING, & p
      end

      define_method :in_screen do | & p |
        in_screen_ending_with _COMMON_BRANCH_PROMPT_ENDING, & p
      end

      def enter_field name, value
        enter_field_selector name
        enter_field_value value
        nil
      end

      define_method :enter_field_selector do |name|
        @session.puts name
        expect_screen_ending_with _COMMON_FIELD_PROMPT_ENDING
        nil
      end

      define_method :enter_field_value do |value|
        @session.puts value
        expect_screen_ending_with _COMMON_BRANCH_PROMPT_ENDING
        nil
      end
    end
  end
end
