require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI_fail_early
    use :CLI

    it "ping the top" do
      invoke 'ping'
      _want_pinged
    end

    it "no arg - intrinsics are listed" do
      __no_arg.index_of_splay.offset_via_operator_symbol[ :ping ] || fail
    end

    it "strange looking operator" do
      invoke "ip_man"
      on_stream :serr
      want "unknown primary or operator: \"ip_man\" (did you mean ip-man?)"
      want_failed_normally_
    end

    it "strange operator - whines" do
      _strange_oper_arg.reason_line == "unrecognized operator: \"zazoozle\"" || fail
    end

    it "strange operator - splays intrinsics" do
      _strange_oper_arg.index_of_splay.offset_via_operator_symbol[ :ping ] || fail
    end

    it "through fuzzy reach an intrinsic" do
      invoke "pin"
      _want_pinged
    end

    it "strange option - explain, splay, invite" do
      invoke '-x'
      want_on_stderr "unknown primary \"-x\""
      want_on_stderr "available primaries: -help and -verbose"
      want_failed_normally_  # #coverpoint1.F
    end

    context "help for root" do

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

      it "operators section - intrinsics are present" do

        h = _main_items.item_offset_via_key
        h[ :ping ] || fail
        h[ :map ] || fail
      end

      it "primaries - intrinsics are present" do

        h = _secondary_items.item_offset_via_key
        h[ :help ] || fail
        h[ :verbose ] || fail
      end

      # (we don't bother checking for descriptions because
      # the state machine parser requires them presently)

      shared_subject :_main_items do
        _sections.main_items.to_index_of_common_item_list
      end

      shared_subject :_secondary_items do
        _sections.secondary_items.to_index_of_common_item_list
      end

      shared_subject :_usage do
        sect = _sections.usage
        sect.want_exactly_one_line
        sect.to_index_of_common_branch_usage_line
      end

      shared_subject :_sections do

        invoke '-h'

        want_common_help_screen_sections_by_ do |sct, o|

          o.want_section "usage" do |sect|
            sct.usage = sect
          end

          o.want_section "description" do |sect|
            sct.description = sect
          end

          o.want_section "operations" do |sect|
            sct.main_items = sect
          end

          o.want_section "primaries" do |sect|
            sct.secondary_items = sect
          end
        end
      end
    end

    # ==

    # -- expectations

    def _want_pinged
      want_on_stderr "hello from tmx"
      want_succeed
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
