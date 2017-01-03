require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI
    use :non_interactive_CLI_fail_early

    it "ping the top" do
      invoke 'ping'
      expect_on_stderr "hello from tmx"
      expect_succeeded
    end

    it "no arg - intrinsics are listed" do
      _these[ :ping ] || fail
    end

    it "strange operator-looking argument - two lines of whining, then invite", wip: true do
      invoke 'zazoozle'
      expect_on_stderr "currently, normal tmx is deactivated -"
      expect "won't parse \"zazoozle\""
      expect_failed_normally_
    end

    it "strange option - explain, invite", wip: true do
      invoke '-x'
      expect_on_stderr "unrecognized option: \"-x\""
      expect_failed_normally_
    end

    shared_subject :_these do
      invoke
      line = nil
      expect_each_on_stderr_by do |line_|
        line = line_
        TRUE
      end
      expect_failed_normally_
      __eek_hash_via_line line
    end

    def __eek_hash_via_line line
      h = {}
      scn = TestSupport_::Library_::StringScanner.new line
      scn.skip( /available operators: / ) || TS_._youve_been_waiting_for_this
      dash = /-/ ; slug = /[a-z][a-z0-9]*(?:-[a-z0-9]+)*/
      _DASH = '-' ; _UNDERSCORE = '_'  # DASH_ UNDERSCORE_
      one = -> do
        scn.skip dash or fail
        s = scn.scan slug
        s || fail
        h[ s.gsub( _DASH, _UNDERSCORE ).intern ] = true
      end
      one[]
      if ! scn.eos?
        comma_rx = /, /
        begin
          if scn.skip comma_rx
            one[]
            redo
          end
          scn.scan( / and / ) || fail
          break
        end while above
        one[]
        scn.eos? || fail
      end
      h
    end

    it "help (a stub for now)", wip: true do
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
