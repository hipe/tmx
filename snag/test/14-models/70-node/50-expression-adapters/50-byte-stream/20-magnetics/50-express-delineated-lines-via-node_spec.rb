# frozen_string_literal: true

require_relative '../../../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node - [..] - express delineated [..]" do

    TS_[ self ]
    use :byte_up_and_downstreams

    context "delineation" do

      it "with 3 things added under 73 chars, delineates to one line" do

        _width 73
        _sub_margin 3
        _fake_ID _six_width_fake_ID

        _message "gary jules - mad word (manic focus remix)"

        scn = _build_scanner

        expect( scn.next_line ).to eql(
          "[#fake]   gary jules - mad word (manic focus remix)\n" )

        expect( scn.next_line ).to be_nil
      end

      it "with one line that is just a bunch of words longer than 73 chars" do

        _width 73
        _sub_margin 0

        _108_chars = %[Los Mangeles started playing "Clarity (PRFFTT & #{
          }Svyable X Ravi Remix)" by Zedd - TableTurner started playing]

        _message _108_chars

        _fake_ID _zero_width_fake_ID

        scn = _build_scanner

        expect( scn.next_line.length ).to eql 74  # exceeds b.c of newline
        expect( scn.line[ 0, 4 ] ).to eql 'Los '
        expect( scn.line[ -4 .. -1 ] ).to eql " by\n"

        expect( scn.next_line[ 0, 7 ] ).to eql 'Zedd - '
        expect( scn.next_line ).to be_nil
      end

      it "long lines will break on dashes, or exceed the limit baring dashes" do

        _width 10
        _sub_margin 0
        _max_lines 5  # was

        _fake_ID _zero_width_fake_ID
        _message "ABC_one_line_-two-line-_tre_line_"

        _actual = _build_line_stream

        want_these_lines_in_array_ _actual do |y|
          y << "ABC_one_line_-\n"
          y << "two-line-\n"
          y << "_tre_line_\n"
        end
      end

      it "gold star" do

        _width 77
        _sub_margin 7
        _fake_ID _six_width_fake_ID

        _message <<-O.chop
1___ 1b__ 2___ 2b__ 3___ 3b__ 4___ 4b__ 5___ 5b__ 6___ 6b__ 7___ 7b__ 8___ 8b__
        O

        scn = _build_scanner
        expect( scn.next_line ).to eql(
"[#fake]       1___ 1b__ 2___ 2b__ 3___ 3b__ 4___ 4b__ 5___ 5b__ 6___ 6b__\n" )

        expect( scn.next_line ).to eql(
"              7___ 7b__ 8___ 8b__\n" )

        expect( scn.next_line ).to be_nil
      end

      def _width d
        @_width_x = d
      end

      def _sub_margin d
        @_sub_margin_x = d
      end

      def _identifier_width x
        @_identifier_width_x = x
      end

      def _max_lines d
        # was
      end

      def _fake_ID x
        @_fake_ID_x = x
      end

      def _message s
        @_message = s
      end

      def _do_prepend_open_tag
        @_do_prepend_open_tag_x = true
      end

      attr_reader :_do_prepend_open_tag_x, :_identifier_width_x

      def _build_line_stream
        scn = _build_scanner
        Common_::MinimalStream.by do
          scn.next_line
        end
      end

      def _build_scanner

        _expag = build_byte_stream_expag_ @_width_x, @_sub_margin_x ,
          _identifier_width_x || 50

        node = Home_::Models_::Node.edit_entity(

          :via, :object, :set, :identifier, @_fake_ID_x,
          :append, :string, @_message )

        node or fail

        y = ::String.new

        _yes = node.express_into_under y, _expag
        _yes or fail

        scanner_via_string_ y
      end

      memoize :_six_width_fake_ID do
        _build_fake_ID '[#fake]'
      end

      memoize :_zero_width_fake_ID do
        _build_fake_ID EMPTY_S_
      end

      def self._build_fake_ID s

        o = ::Object.new

        o.send :define_singleton_method, :express_into_under do | y, _ |
          y << s
          ACHIEVED_
        end

        o
      end
    end
  end
end
