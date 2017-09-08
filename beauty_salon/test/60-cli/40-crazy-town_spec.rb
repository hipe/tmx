# frozen_string_literal: true
require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] CLI - crazy-town' do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI
    use :my_CLI

    dig = %w( crazy-town ).freeze
    # help = '-h'

    context '0) missing required' do

      given do
        argv( * dig )
      end

      it 'first line is a splay' do
        _actual = first_line_string
        _actual =~ /\Aavailable operators and primaries: / || fail
      end

      it 'second line invite' do
        _expect_invite_line second_and_final_line_string
      end

      it 'fails' do
        fails
      end

      def CLI_options_for_expect_stdout_stderr
        X_ct_use_real_filesystem
      end
    end

    # (we don't cover the helpscreen because it's too big..)
    # but sign off on the above choice after #open [#023]

    def _expect_invite_line actual
      actual == "try 'chimmy crazy-town -h'\n" || fail
    end

    # ==

    X_ct_use_real_filesystem = -> cli do

      cli.filesystem = ::File
    end

    # ==
    # ==
  end
end
# #born during wean off matryoshka
