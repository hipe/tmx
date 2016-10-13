require_relative '../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics - CLI" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics_CLI

    _OPERATION = 'magnetics-viz'

    context "ping-like" do

      given do
        argv _OPERATION, '-x'
      end

      it "invalid option" do
        _be_this = be_line "invalid option: -x"
        first_line.should _be_this
      end

      it "invite" do
        _be_this = be_line :styled, /\Asee 'xyzi magnetics-viz -h' for more about options\z/
        last_line.should _be_this
      end
    end

    context "(verify content)" do

      given do
        argv _OPERATION, 'shlum-shlum'
      end

      it "the output looks like a digraph (outer lines)" do

        a = niCLI_state.lines
        a.first.string == "digraph g {\n" or fail
        a.last.string == "}\n" or fail
      end

      it "main thing points to the 'one of these' node" do

        _reflection.A_points_to_this_ONE_OF_THESE_node :hover_craft, 1 or fail
      end

      it "the 'one of these' nodes points to thse two" do

        o = _reflection
        o.this_ONE_OF_THESE_node_points_to_this_ALL_OF_THESE_node 1, 1
        o.this_ONE_OF_THESE_node_points_to_B 1, :amazon
      end

      it "the 'all of these' node poins to these two" do

        o = _reflection
        o.this_ALL_OF_THESE_node_points_to_B 1, :cunning
        o.this_ALL_OF_THESE_node_points_to_B 1, :ingenuity
      end

      it "label for these two is normal" do
        o = _reflection
        o.label_for( :amazon ) == "amazon" || fail
        o.label_for( :ingenuity ) == "ingenuity" || fail
      end

      it "label for 'one of these' is parenthesized" do
        _label_for_one_of_these.should _have_parenthesis
      end

      it "label for 'all of these' is parenthesized" do
        _label_for_all_of_these.should _have_parenthesis
      end

      def _have_parenthesis
        match %r(\A\(.+\)\z)
      end

      it "label for 'one of these' does not wordwrap" do
        _label_for_one_of_these.include? 'one of these' or fail
      end

      it "label for 'all of these' does not wordwrap" do
        _label_for_all_of_these.include? 'all of these' or fail
      end

      shared_subject :_label_for_one_of_these do
        _reflection.label_for_ONE_OF_THESE_node 1
      end

      shared_subject :_label_for_all_of_these do
        _reflection.label_for_ALL_OF_THESE_node 1
      end

      it "label for \"hover craft\" word wraps" do
        _ = _reflection.label_for :hover_craft
        _ == 'hover\ncraft' || fail
      end

      shared_subject :_reflection do

        _st = Common_::Stream.via_nonsparse_array niCLI_state.lines, & :string

        TS_::Magnetics::Dotfile_Graph::Reflection.via_line_stream _st
      end

      def for_expect_stdout_stderr_prepare_invocation invo

        dir = _this_mock_dir_class
        invo.filesystem_by { dir }
        NIL_
      end

      shared_subject :_this_mock_dir_class do

        make_mock_directory_class_ :X_MAG_MOCK_DIR_CLASS_1, %w(
          .
          ..
          hover-craft-via-amazon.rb
          hover-craft-via-cunning-and-ingenuity.rb
        ).freeze
      end

      def make_mock_directory_class_ const, s_a

        o = ::Module.new

        TS_.const_set const, o

        _dir = TS_::Magnetics::MockDirectory.via_all_entries_array s_a

        h = {}
        h[ 'shlum-shlum' ] = _dir

        o.send :define_singleton_method, :new do |s|
          h.fetch s
        end
        o
      end
    end
  end
end
