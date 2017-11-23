# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town unparse magnetics - ', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_unparsing

    context 'control flow coverage 750' do  # #coverpoint3.7

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << "go = -> ( (foo, bar) ) do\n"
          y << "end\n"
          y << "while go[]\n"
          y << "  hi\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          go = -> ( (foo, bar) ) do
          end
          while go[]
            hi
          end
        O
      end
    end
  end
end
# #extracted.
