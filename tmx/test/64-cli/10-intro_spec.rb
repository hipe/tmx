require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - intro" do

    TS_[ self ]
    use :CLI
    use :non_interactive_CLI_fail_early

    # IN PROGRESS - several of these tests have wipped legacy counterparts
    # over in the sibling file (next level up by number). (they are there
    # and not here for historical reasons). once dust settles, eliminate
    # those others. but while #open/#wish [#018] [#019] [#020] they are
    # being kept there for reference.

    it "strange argument - two lines of whining, then invite" do
      invoke 'zazoozle'
      expect_on_stderr "currently, normal tmx is deactivated -"
      expect "won't parse \"zazoozle\""
      expect_failed_normally_
    end

    it "strange option - explain, invite" do
      invoke '-x'
      expect_on_stderr "unrecognized option: \"-x\""
      expect_failed_normally_
    end

    it "help (a stub for now)" do
      invoke '-h'
      expect_on_stderr %r(\Ausage: tmz \{ test-all \| )
      expect_empty_puts
      expect "description: experiment.."
      expect_empty_puts
      expect "operations:"

      _a = "reporting operations", "generate the", "stream of nodes"
      scn = Common_::Polymorphic_Stream.via_array _a

      p = -> line do
        if line
          exp = scn.current_token
          if line.include? exp
            scn.advance_one
            if scn.no_unparsed_exists
              p = MONADIC_EMPTINESS_
            end
          end
        end
        NIL
      end

      expect_each_by do |line|
        p[ line ]
      end

      expect_succeeded

      if ! scn.no_unparsed_exists
        fail "never found: #{ scn.current_token.inspect }"
      end
    end
  end
end
