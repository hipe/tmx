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

    it "strange option - explain, splay, invite" do
      invoke '-x'
      expect_on_stderr "unknown primary: \"-x\""
      expect_on_stderr "available primaries: -help"
      expect_failed_normally_  # #coverpoint-1-F
    end

    context "help" do

      it "usage - head and tail" do
        o = _usage
        o.head == "usage: tmz " || fail
        o.tail == " [opts]" || fail
      end

      it "usage - items - intrinsics are present" do
        h = _usage.item_index
        h[ :ping ] || fail
        h[ :map ] || fail
      end

      it "description" do
        _sections.description.emissions.first.string.include? 'experiment' or fail
      end

      it "items section - intrinsics are present" do

        h = _items.item_offset_via_key
        h[ :ping ] || fail
        h[ :map ] || fail
      end

      # (we don't bother checking for descriptions because
      # the state machine parser requires them presently)

      shared_subject :_items do
        _sections.items.to_index_of_common_item_list
      end

      shared_subject :_usage do
        sect = _sections.usage
        sect.expect_exactly_one_line
        sect.to_index_of_common_branch_usage_line
      end

      shared_subject :_sections do

        invoke '-h'

        expect_common_help_screen_sections_by_ do |sct, o|

          o.expect_section "usage" do |sect|
            sct.usage = sect
          end

          o.expect_section "description" do |sect|
            sct.description = sect
          end

          o.expect_section "operations" do |sect|
            sct.items = sect
          end
        end
      end
    end

    # ==

    # ==

    # -- expectations

    def _expect_pinged
      expect_on_stderr "hello from tmx"
      expect_succeeded
    end

    # -- setup

    def __no_arg
      invoke
      finish_with_common_machine_
    end

    shared_subject :_strange_oper_arg do
      invoke 'zazoozle'
      finish_with_common_machine_
    end
  end
end
