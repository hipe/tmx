require_relative '../test-support'

module Skylab::Treemap::TestSupport

  describe "[tr] models - node" do

    TS_[ self ]
    use :memoizer_methods

    it "loads (keep this test - strange autoloading)" do
      _subject_module || fail
    end

    context "build one node" do

      it "builds" do
        _subject || fail
      end

      it "read these two datapoints" do
        o = _subject
        o.main_quantity == 66.77 || fail
        o.label_string == 'jumanji' || fail
      end

      shared_subject :_subject do
        _subject_module.define do |o|
          o.label_string = 'jumanji'
          o.main_quantity = 66.77
        end
      end
    end

    context "write then read some childs" do

      it "builds" do
        _subject || fail
      end

      it "looks alright" do

        _node = _subject

        _st = __line_stream_via_big_string <<-HERE.gsub( %r(^[ ]{10}), '' )  # EMPTY_S_
          (branch)
           ├child 1 - 12.34
           └(branch)
             ├child 3 - 3.3
             └child 4 - 9.04
        HERE

        _expect_etc _node, _st
      end

      def __line_stream_via_big_string big_s
        Home_.lib_.basic::String::LineStream_via_String[ big_s ]
      end

      def _expect_etc node, exp_st

        _act_st = __build_line_stream_via_node_for_debugging node

        TestSupport_::Expect_Line::Streams_have_same_content[ _act_st, exp_st, self ]
      end

      def __build_line_stream_via_node_for_debugging node

        _Tree = Home_.lib_.basic::Tree
        _ = _Tree::Expression_Adapters__::Text::Actors::Build_classified_stream

        _st = _[ node ]

        sep = ' - '

        _line_stream = _st.map_by do |cfn|
          node = cfn.node
          a = []
          x = node.label_string
          x and a.push x
          x = node.main_quantity
          x and a.push x
          if a.length.nonzero?
            _slug = a.join sep
          else
            _slug = '(branch)'
          end
          "#{ cfn.prefix_string }#{ _slug }\n"
        end
      end

      shared_subject :_subject do

        _subject_module.define do |oo|

          oo.add_child_by do |o|
            o.label_string = 'child 1'
            o.main_quantity = 12.34
          end

          oo.add_child_by do |o_|

            o_.add_child_by do |o|
              o.label_string = 'child 3'
              o.main_quantity = 3.3
            end

            o_.add_child_by do |o|
              o.label_string = 'child 4'
              o.main_quantity = 9.04
            end
          end
        end
      end
    end

    def _subject_module
      Home_::Models::Node
    end
  end
end
