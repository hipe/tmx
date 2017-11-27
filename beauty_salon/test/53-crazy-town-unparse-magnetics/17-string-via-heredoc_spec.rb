# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town unparse magnetics - string via heredoc', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_unparsing

    context '(500) ideal simple' do  # #coverpoint5.1

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << "foo <<-HERE.length, 'ohai'\n"
          y << "  one\n"
          y << "  two\n"
          y << "HERE\n"
          y << "line_after"
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          foo <<-HERE.length, 'ohai'
            one
            two
          HERE
          line_after
        O
      end
    end
  end
end
# #extracted.
