# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town unparse magnetics - string via variable', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_unparsing

    context 'variables coverage 250 (a regression)' do  # #coverpoint5.6

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << "-> wat do\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          -> wat do
          end
        O
      end
    end

    context 'variables coverage 375' do  # #coverpoint3.9

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << "frob do |em|\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          frob do |em|
          end
        O
      end
    end

    context 'variables coverage 500' do  # #coverpoint3.5

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << "def frob * args, & wee\n"
          y << "  @qq_qq = :xx\n"
          y << "  @xx_xx\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O

          def frob * args, & wee
            @qq_qq = :xx
            @xx_xx
          end
        O
      end
    end

    context 'control flow coverage 500' do

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << "if @xx\n"
          y << "  @yy if @qq\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          if @xx
            @yy if @qq
          end
        O
      end
    end
  end
end
# #extracted.
