require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - intro" do

    TS_[ self ]
    use :CLI
    use :non_interactive_CLI_fail_early

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

    if false  # wip: true

    # (eventually these are supposed to melt out to their
    #  respective sidesystems)

    # (somewhat at odds with other nearby test nodes,
    #  this is testing *our* tmx, and not *the* tmx)

    use :CLI

    _ARG = 'ping'.freeze
    _FLAG = '--ping'.freeze

    # -10
    it "beauty salon" do
      _against 'beauty-salon', _ARG
      _expect_common
    end

    # -7
    it "bnf2treetop" do
      _against 'bnf2treetop', _FLAG
      _expect_common
    end

    # -5
    it "code metrics" do
      _against 'code-metrics', _ARG
      _expect_common
    end

    # -6
    it "css-convert" do

      _against 'css-convert', 'convert', _FLAG
      @_slug = 'css-convert'
      _expect_common
    end

    # -4
    it "cull" do
      _against 'cull', _ARG
      _expect_common
    end

    # -8
    it "flex2treetop" do
      _against 'flex2treetop', _ARG
      _expect_common
    end

    # -12
    it "permute" do
      _against 'permute', _ARG
      _expect_common_start
      @exitstatus.zero? || fail
    end

    # -13
    it "slicer" do
      _against 'slicer', _ARG
      _expect_common
    end

    # -3
    it "snag" do
      _against 'snag', _ARG
      _expect_common
    end

    # -2
    it "tan man" do
      _against 'tan-man', _ARG
      _expect_common
    end

    # -11
    it "treemap" do
      _against 'treemap', _ARG
      _expect_common
    end

    # -1
    it "xargs-ish-i" do
      _against 'xargs-ish-i', _FLAG
      _expect_succeeded
    end

    # -9
    it "yacc2treetop" do
      _against 'yacc2treetop', _FLAG
      _expect_common
    end

    def _against * argv

      invoke( * argv )
      @_argv = argv
      NIL_
    end

    _SPACE = ' '
    _UNDERSCORE = '_'

    define_method :_expect_common do

      _expect_common_start

      @exitstatus.should eql :"hello_from_#{ @_s_a.join _UNDERSCORE }"
    end

    define_method :_expect_succeeded do

      _expect_common_start
      @exitstatus.should be_zero
    end

    define_method :_expect_common_start do

      @_slug ||= @_argv.fetch( -2 )
      @_s_a = @_slug.split Home_::DASH_

      expect :e, "hello from #{ @_s_a.join _SPACE }."

      expect_no_more_lines
    end
    end  # if false
  end
end
