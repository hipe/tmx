require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - multi mode argument scanner - subtract primaries" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      subject_module_
    end

    # -

      it "(hard to break up)" do

        scn = subject_module_.define do |o|

          o.front_scanner_tokens :fleef

          o.subtract_primary :ding_dong, :Dinger_Donger

          _ = Common_::Scanner.via_array %w( -zing-bling zang )

          o.user_scanner _
        end

        sym = scn.head_as_normal_symbol
        sym == :fleef || fail

        scn.advance_one

        _no = scn.no_unparsed_exists
        _no && fail

        _sym = scn.head_as_primary_symbol
        _sym == :ding_dong || fail

        scn.advance_one

        _no = scn.no_unparsed_exists
        _no && fail

        _sym = scn.head_as_normal_symbol
        _sym == :Dinger_Donger || fail

        scn.advance_one

        _no = scn.no_unparsed_exists
        _no && fail

        _sym = scn.head_as_primary_symbol
        _sym == :zing_bling || fail

        scn.advance_one

        _no = scn.no_unparsed_exists
        _no && fail

        _sym = scn.head_as_normal_symbol
        _sym == :zang || fail

        scn.advance_one

        _yes = scn.no_unparsed_exists
        _yes || fail

        # - gives it to the back via the first scanner

        # - fail identically to unrecognized back primary
      end

      it "when primary is expected but not provided" do

        el = event_log_.for self

        scn = subject_module_.define do |o|

          _ = Common_::Scanner.via_array %w( zing-bling zang )

          o.user_scanner _

          o.emit_into el.handle_event_selectively
        end

        _no = scn.head_as_primary_symbol  # might be #feature-island #scn-coverpoint-2

        false == _no || fail

        em = el.gets

        em.channel_symbol_array == %i( error expression parse_error primary_had_poor_surface_form ) || fail

        _act = em.express_into_under "", expag_

        _act == 'unknown primary "zing-bling"' || fail
      end

      it "when use a primary that was subtracted" do

        el = event_log_.for self

        scn = subject_module_.define do |o|

          o.subtract_primary :ding_dong, :Dinger_Donger

          _ = Common_::Scanner.via_array %w( -ding-dong zang )

          o.user_scanner _

          o.emit_into el.handle_event_selectively
        end

        _sym = scn.head_as_primary_symbol
        _sym == :ding_dong || fail

        scn.advance_one

        scn.no_unparsed_exists && fail

        _sym = scn.head_as_normal_symbol
        _sym == :Dinger_Donger || fail

        scn.advance_one

        scn.no_unparsed_exists && fail

        _failed = scn.head_as_primary_symbol
        _failed == false || fail

        em = el.gets

        em.channel_symbol_array == %i( error expression parse_error subtracted_primary_was_referenced ) || fail

        _act = em.express_into_under "", expag_
        _act == 'unknown primary "-ding-dong"' || fail
      end

    # -

    def expag_
      X_niCLI_mmas_EXPAG
    end

    X_niCLI_mmas_EXPAG = class X_niCLI_mmas_Expag

      alias_method :calculate, :instance_exec

      def ick_oper x  # assimilated `say_strange_branch_item` at #history-A
        x.respond_to? :ascii_only? or self._WHERE
        x.inspect
      end

      new
    end

    def subject_module_
      Home_::NonInteractiveCLI::MultiModeArgumentScanner
    end
  end
end
# :#history-A (probably temporary)
