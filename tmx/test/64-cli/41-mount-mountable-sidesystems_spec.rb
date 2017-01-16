require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - mount moutable one-offs" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI_fail_early
    use :CLI

    # some parts of this test rely on #real intrinsic operations and/or
    # primaries, the rest are per the indicated dummy
    # defined in this file

    context "fuzzy - relevant nodes for both intrinsics and sidesystems appear" do

      it "relevant names of the sidesystems AND intrinsics" do
        h = _the_operators_hash
        h[ :mapelthorpe ] || fail
        h[ :mocking_jay ] || fail
        # ..
        h[ :map ] || fail  # #real
      end

      it "the other sidesystem name(s) are not, nor are primaries" do
        _the_operators_hash[ :wolly_polly ] && fail
        _no_primaries
      end

      shared_subject :_subject do
        invoke 'm'
        # ambiguous primary "m" - did you mean map, mocking-jay or mapelthorpe?
        parse_splay_ %r(\Aambiguous primary "m" - did you mean )
      end
    end

    context "no arg - suggestions for all appear" do

      it "all 3 sidesystems" do  # mocked
        _all_sidesystems
      end

      it "some intrinsic operators" do  # #real
        _some_intrinsics
      end

      it "some primaries" do  # #real
        _some_primaries
      end

      shared_subject :_subject do
        invoke  # no args
        # available operators and primaries: test-all, reports, map, ping, wolly-polly, mocking-jay, mapelthorpe, -help and -verbose
        parse_splay_ %r(\Aavailable operators and primaries: )
      end
    end

    context "unrec - suggestions for all *operators* appear" do

      it "all sidesystems and intrinsics" do  # sidesystems mocked, inrinsics #real
        _all_sidesystems
        _some_intrinsics
      end

      it "no primaries" do  # #real
        _no_primaries
      end

      shared_subject :_subject do
        invoke 'wabuncle'
        expect_on_stderr 'unrecognized operator: "wabuncle"'
        # available operators: test-all, reports, map, ping, wolly-polly, mocking-jay and mapelthorpe
        parse_splay_ %r(\Aavailable operators: )
      end
    end

    it "successfull call to mounted sidesystem (dummy)" do
      invoke 'wolly-polly'
      expect_on_stderr "hello from dummy ZimZum::WollyPolly::CLI"
      expect_succeeded
    end

    context "help for mounted sidesystem (dummy)" do

      it "all lines from the easy way" do
        invoke 'mocking-jay', '-h'
        _expect_same_help_for_mocking_jay
      end

      it "all lines from the hard way" do
        invoke '-h', 'mocking-jay'
        _expect_same_help_for_mocking_jay
      end

      def _expect_same_help_for_mocking_jay
        expect_on_stderr "i am help for tmz mocking-jay"
        expect_succeeded
      end
    end

    # -- assertions

    def _all_sidesystems  # (mocked)
      h = _the_operators_hash
      h[ :mapelthorpe ] || fail
      h[ :mocking_jay ] || fail
      h[ :wolly_polly ] || fail
    end

    def _some_intrinsics  # #real
      _the_operators_hash[ :map ] || fail
    end

    def _no_primaries
      _the_primaries_hash && fail
    end

    def _some_primaries

      h = _the_primaries_hash
      h[ :help ] || fail
      h[ :verbose ] || fail
    end

    # -- assertion support

    def _the_operators_hash
      _subject.offset_via_operator_symbol
    end

    def _the_primaries_hash
      _subject.offset_via_primary_symbol
    end

    # -- memoized instances (fixtures)

    def mock_installation_
      # popular default. change as appropriate for your case
      mock_installation_one
    end

    shared_subject :mock_installation_one do

      define_mock_installation_ do |inst|

        inst.add_fake_sidesystem 'wolly_polly'
        inst.add_fake_sidesystem 'mocking_jay'
        inst.add_fake_sidesystem 'mapelthorpe'
      end
    end

    # -- assertion support (support)

    def parse_splay_ rx

      on_stream :serr

      line = nil
      expect_line_by do |lin|
        line = lin
        NIL
      end

      expect_failed_normally_

      Zerk_test_support_[]::CLI::IndexOfSplay_via_Line.define do |o|
        o.head_regexp = rx
        o.line = line
      end.execute
    end

    def prepare_CLI cli

      mock_inst = mock_installation_

      cli.send :define_singleton_method, :_installation do  # per :#testpoint
        mock_inst
      end

      NIL
    end

    # --
  end
end
# #born for big cleanup
