require_relative '../../../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node [..] delineate" do

    extend TS_
    use :byte_stream_support

    context "delineation" do

      it "with 3 things added under 73 chars, delineates to one line" do

        _width 73
        _sub_margin 3
        _fake_ID _six_width_fake_ID

        _message "gary jules - mad word (manic focus remix)"

        scn = _build_scanner

        scn.next_line.should eql(
          "[#fake]   gary jules - mad word (manic focus remix)\n" )

        scn.next_line.should be_nil
      end

      it "with one line that is just a bunch of words longer than 73 chars" do

        _width 73
        _sub_margin 0

        _108_chars = %[Los Mangeles started playing "Clarity (PRFFTT & #{
          }Svyable X Ravi Remix)" by Zedd - TableTurner started playing]

        _message _108_chars

        _fake_ID _zero_width_fake_ID

        scn = _build_scanner

        scn.next_line.length.should eql 74  # exceeds b.c of newline
        scn.line[ 0, 4 ].should eql 'Los '
        scn.line[ -4 .. -1 ].should eql " by\n"

        scn.next_line[ 0, 7 ].should eql 'Zedd - '
        scn.next_line.should be_nil
      end

      it "long lines will break on dashes, or exceed the limit baring dashes" do

        _width 10
        _sub_margin 0
        _max_lines 5  # was

        _fake_ID _zero_width_fake_ID
        _message "ABC_one_line_-two-line-_tre_line_"

        scn = _build_scanner

        scn.next_line.should eql "ABC_one_line_-\n"
        scn.next_line.should eql "two-line-\n"
        scn.next_line.should eql "_tre_line_\n"
        scn.next_line.should be_nil
      end


      def _width d
        @_width_x = d
      end

      def _sub_margin d
        @_sub_margin_x = d
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

      attr_reader :_do_prepend_open_tag_x

      def _build_scanner

        _expag = build_byte_stream_expag_ @_width_x, @_sub_margin_x , 50

        node = Snag_::Models_::Node.new_via__message__ @_message

        node.instance_variable_set :@ID, @_fake_ID_x

        y = ""

        _yes = node.express_into_under y, _expag
        _yes or fail

        scanner_via_string_ y
      end

      memoize_ :_six_width_fake_ID do
        _build_fake_ID '[#fake]'
      end

      memoize_ :_zero_width_fake_ID do
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