require_relative 'test-support'

module Skylab::Snag::TestSupport::Models::Node
  # Quickie.
  describe "[sg]::Models::Node::Controller" do
    extend Node_TestSupport
    context "delineation" do
      it "with 3 things added under 73 chars, delineates to one line" do
        node = build_node
        node.date_string = '2013-01-04'
        node.do_prepend_open_tag = true
        node.message = "gary jules - mad word (manic focus remix)"
        node.first_line_body.object_id.should eql(
        node.first_line_body.object_id )
        node.first_line_body.frozen?.should eql( true )
        node.first_line_body.should eql(
          '#open gary jules - mad word (manic focus remix) 2013-01-04' )
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

    # --*--


    class Controller_RC_Mock
      def call_digraph_listeners name, pay
        Stderr_[].puts "WAT: #{ [name, pay].inspect }"
      end
    end

    define_method :build_node do
      node = Snag_::Models::Node::Controller.new Controller_RC_Mock.new
      node.instance_variable_set '@extra_lines_header', ''
      node
    end
  end
end
