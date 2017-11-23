# frozen_string_literal: true

require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town unparse magnetics - ', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_unparsing

    context 'blocks - 100' do  # #coverpoint6.1

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << "frob do |em|\n"
          y << "  em + 1\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          frob do |em|
            em + 1
          end
        O
      end
    end
  end
end
# #extracted.
