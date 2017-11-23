# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town unparse magnetics - ', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_unparsing

    context 'method call coverage 175 - brackets with args' do  # #coverpoint3.8

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << "md = nil\n"
          y << 'md[ :foo ]'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          md = nil
          md[ :foo ]
        O
      end
    end

    context 'method call coverage 250 - prefix operator' do  # #coverpoint3.4

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << 'map( & :wa_hoo )'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          map( & :wa_hoo )
        O
      end
    end

    context 'method call coverage 250 - infix operator' do  # #coverpoint3.6

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << "left_x = nil ; right_x = 3.33  # see\n"
          y << 'left_x == right_x || frob'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          left_x = nil ; right_x = 3.33  # see
          left_x == right_x || frob  # say
        O
      end
    end

    context 'method call coverage 500 - NOT ("!") as send' do  # #coverpoint3.3

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << "! @me"
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          ! @me  # no see
        O
      end
    end

    context 'method call coverage 750' do  # coverpoint3.5

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << '@jim[ 33 ] = "hi"'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          @jim[ 33 ] = "hi"  # no see
        O
      end
    end
  end
end
# #extracted.
