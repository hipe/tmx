require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - dig scanner - front tokens" do

    TS_[ self ]
    use :non_interactive_CLI_argument_scanner

    it "loads." do
      subject_module_
    end

    it "`front_scanner_tokens`" do

      as = define_by_ do |o|

        o.front_scanner_tokens :flipper, :florper

        o.user_scanner real_scanner_for_ "hi"
      end

      as.no_unparsed_exists && fail
      as.head_as_primary_symbol == :flipper || fail

      as.advance_one
      as.no_unparsed_exists && fail
      as.head_as_primary_symbol == :florper || fail

      as.advance_one
      as.no_unparsed_exists && fail
      as.head_as_is == "hi" || fail

      as.advance_one
      as.no_unparsed_exists || fail
    end
  end
end
