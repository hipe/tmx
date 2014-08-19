require_relative 'test-support'

module Skylab::Snag::TestSupport::Models::Node

  describe "[sg] models node controller" do

    extend TS_

    context "delineation" do

      it "with 3 things added under 73 chars, delineates to one line" do
        node = build_node
        node.do_prepend_open_tag = true
        node.message = "gary jules - mad word (manic focus remix)"
        node.first_line_body.object_id.should eql(
        node.first_line_body.object_id )
        node.first_line_body.frozen?.should eql( true )
        node.first_line_body.should eql(
          '#open gary jules - mad word (manic focus remix)' )
      end

      it "with one line that is just a bunch of words longer than 73 chars" do
        _109_chars = %[Los Mangeles started playing "Clarity (PRFFTT & #{
        }Svyable X Ravi Remix)" by Zedd - TableTurner started playing]
        node = build_node
        node.message = _109_chars
        node.first_line_body.length.should eql( 68 )
        node.first_line_body[ -7 .. -1 ].should eql( ' X Ravi' )
        el = node.extra_line_a
        el.length.should eql( 1 )
        el.first.should eql( 'Remix)" by Zedd - TableTurner started playing' )
      end

      it "with one long line that looks (to it) line one long word" do
        node = build_node
        node.instance_variable_set :@do_prepend_open_tag_ws, false
        node.instance_variable_set :@line_width, 10 # other thing is at 7
        node.instance_variable_set :@max_lines, 5
        long_line = "ABC_one_line_-two-line-_tre_line_"
        node.message = long_line
        node.first_line_body.should eql( 'ABC' )
        node.extra_line_a[0].should eql( '_one_line_' )
        node.extra_line_a[1].should eql( '-two-line-' )
        node.extra_line_a[2].should eql( '_tre_line_' )
        node.extra_line_a.length.should eql(3)
      end
    end

    class Listener_Mock
      def receive_error_string pay
        Stderr_[].puts "WOW: #{ [ pay ].inspect }"
      end
      def receive_info_string pay
        Stderr_[].puts "OK: #{ pay }"
      end
      def send_to_listener name, pay
        Stderr_[].puts "WAT: #{ [ pay].inspect }"
      end
    end

    define_method :build_node do
      node = Snag_::Models::Node.build_controller Listener_Mock.new, :_A_C_
      node.instance_variable_set '@extra_lines_header', ''
      node
    end
  end
end
