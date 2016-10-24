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

          _ = Common_::Polymorphic_Stream.via_array %w( -zing-bling zang )

          o.user_scanner _
        end

        sym = scn.head_as_normal_symbol
        sym == :fleef || fail

        scn.advance_one

        _no = scn.no_unparsed_exists
        _no && fail

        _sym = scn.head_as_normal_symbol_for_primary
        _sym == :ding_dong || fail

        scn.advance_one

        _no = scn.no_unparsed_exists
        _no && fail

        _sym = scn.head_as_normal_symbol
        _sym == :Dinger_Donger || fail

        scn.advance_one

        _no = scn.no_unparsed_exists
        _no && fail

        _sym = scn.head_as_normal_symbol_for_primary
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

      it "when primary is expected but not provided"

      it "when use a primary that was subtracted"

    # -

    context "add priamary (other file)"

    def subject_module_
      Home_::NonInteractiveCLI::MultiModeArgumentScanner
    end
  end
end
