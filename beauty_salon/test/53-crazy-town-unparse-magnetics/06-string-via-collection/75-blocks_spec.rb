# frozen_string_literal: true

require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town unparse magnetics - ', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_unparsing

    it 'this (12)' do  # #coverpoint6.4

      orig = '( 1 + 2 ).la_la'
      _sn = structured_node_via_string_ orig
      _have = to_code_losslessly_ _sn
      _have == orig || fail
    end

    context 'single-line proc - no args (25)' do  # #coverpoint6.2

      it 'ok' do
        _hi = build_string_
        _hi == '-> { :hi }' || fail
      end

      def structured_node_
        structured_node_via_string_ <<~O
          -> { :hi }
        O
      end
    end

    context 'single-line proc (50)' do

      it 'ok' do
        _hi = build_string_
        _hi == '-> x { x }' || fail
      end

      def structured_node_
        structured_node_via_string_ <<~O
          -> x { x }
        O
      end
    end

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
