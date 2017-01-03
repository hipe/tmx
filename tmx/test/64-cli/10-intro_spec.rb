require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI
    use :non_interactive_CLI_fail_early

    it "ping the top" do
      invoke 'ping'
      _expect_pinged
    end

    it "no arg - intrinsics are listed" do
      __no_arg.index_of_splay.offset_via_operator_symbol[ :ping ] || fail
    end

    it "strange operator - whines" do
      _strange_oper_arg.reason_line == "unrecognized operator: \"zazoozle\"" || fail
    end

    it "strange operator - splays intrinsics" do
      _strange_oper_arg.index_of_splay.offset_via_operator_symbol[ :ping ] || fail
    end

    it "through fuzzy reach an intrinsic" do
      invoke "pin"
      _expect_pinged
    end

    it "strange option - explain, invite", wip: true do
      invoke '-x'
      expect_on_stderr "unrecognized option: \"-x\""
      expect_failed_normally_
    end

    def __no_arg
      invoke
      finish_with_common_machine_
    end

    shared_subject :_strange_oper_arg do
      invoke 'zazoozle'
      finish_with_common_machine_
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

    def _expect_pinged
      expect_on_stderr "hello from tmx"
      expect_succeeded
    end
  end
end
