require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - ARGV generically" do

    # ("generically" as in we're not parsing any feature-specific options)

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI_fail_early
    use :quickie

    it "strange args won't drop into recursive runner FOR NOW.." do
      # (but now this is #wish [#030.4])
      invoke 'wizz', 'popper'
      expect_on_stderr "unexpected arguments: \"wizz\" [..]"
      expect_CLI_failed_commonly_
    end  # :#here

    it "strange options" do
      invoke '--zizzy', '-h', 'no-see'
      expect_on_stderr 'invalid option: --zizzy'
      expect_CLI_failed_commonly_
    end

    it "help screen!" do
      # (hand-written #[#ze-054] help screen parser.)
      invoke '-h'  # NOTE - if you pass an arg it will activate case #here
      on_stream :serr
      p = nil
      blank_line_then = -> p_ do
        p = -> line do
          line.nil? || fail
          p = p_
        end
      end
      rx = /--([a-z]+(?:-[a-z]+)*)/
      seen = {}
      item = -> line do
        md = rx.match line
        # ..
        seen[ md[1].gsub( Home_::DASH_, Home_::UNDERSCORE_ ).intern ] = true
      end
      options = -> line do
        line == "options:" || fail
        p = item
      end
      p = -> line do
        line == "usage: ruby TEST_FILE [options]" || fail
        blank_line_then[ options ]
      end
      expect_each_by do |line|
        p[ line ]
        NIL
      end
      expect_succeeded

      seen.delete( :help ) || fail
      seen.delete( :tag ) || fail
      if seen.length.nonzero?
        fail "sign off on these new additions to your help screen: (#{ seen.keys * ', ' })"
      end
    end

    # ==

    def expect_CLI_failed_commonly_
      expect "try 'ruby zizzy-the-test-file -h' for help"
      expect_failed
    end

    # ==

    memoize :program_name_string_array do
      %w( zizzy-the-test-file )
    end

    # ==

    def toplevel_module_
      toplevel_module_with_rspec_not_loaded_
    end

    def kernel_module_
      kernel_module_with_rspec_not_loaded_
    end

    # ==
  end
end
# #born
