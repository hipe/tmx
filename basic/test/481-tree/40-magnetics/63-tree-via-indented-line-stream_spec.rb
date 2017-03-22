require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - via indented line stream" do

    TS_[ self ]
    use :expect_event
    use :tree

    it "none" do
      _against_lines nil
      expect_no_events
      @tree.should be_nil
    end

    it "one" do
      _against_lines _dedent <<-HERE
        + beeble
      HERE
      @tree.value_x.should be_nil
      @tree.parent.should be_nil
      @tree.children_count.should eql 1
      tree = @tree.children.first
      tree.value_x.should eql "beeble\n"
      tree.parent.object_id.should eql @tree.object_id
      tree.children_count.should be_zero
      tree.children.should be_nil
      expect_no_events
    end

    it "when a line does not have the glyph" do

      _against_lines _dedent <<-HERE
        hi + no
      HERE

      @tree.should eql false

      expect_not_OK_event_ :line_does_not_have_glyph

      expect_no_more_events
    end

    it "two in a row at the same level" do
      _against_lines _dedent <<-HERE
         + foo
         + bar
      HERE
      @tree.children_count.should eql 2
      @tree.children.length.should eql 2
      o, x = @tree.children
      o.value_x.should eql "foo\n"
      x.value_x.should eql "bar\n"
      o.parent.object_id.should eql x.parent.object_id
      o.parent.object_id.should eql @tree.object_id
      o.children_count.should be_zero
      x.children_count.should be_zero
      o.children.should be_nil
      x.children.should be_nil
    end

    it "strange de-indent" do
      _against_lines _dedent <<-HERE
          + foo
         + bar
      HERE
      @tree.should eql false
      expect_not_OK_event :invalid_dedent
      expect_no_more_events
    end

    it "one child" do
      _against_lines _dedent <<-HERE
          + foo
              + bar
      HERE
      @tree.children_count.should eql 1
      o = @tree.children.first
      o.children_count.should eql 1
      x = o.children.first
      x.children_count.should be_zero
      x.value_x.should eql "bar\n"
    end

    it "step back two" do
      _against_lines _dedent <<-HERE
          + foo
            + bar
              + baz
          + boffo
      HERE
      _to_normal_string.should eql _dedent <<-O
        + foo
          + bar
            + baz
        + boffo
      O
    end

    it "canonical complex case" do
      omg = _dedent <<-HERE
        + document
          + head
          + body
            + element 1
              + lone wolf
                + and cub
            + element 2
              + sub1
              + sub2
              + sub3
            + element 3
              + sub4
          + foot
      HERE
      _against_lines omg
      _to_normal_string.should eql omg
      expect_no_events
    end

    it "`build_using` allows you to map the received string values to whatever" do
      @handle_build = -> line, parent do
        if parent.parent
          :"#{ parent.value_x }_#{ line.chop! }"
        else
          :"top_#{ line.chop! }"
        end
      end
      _against_lines _dedent <<-O
        + foo
          + bar
        + baz
      O
      @tree.children.first.value_x.should eql :top_foo
      @tree.children.first.children.first.value_x.should eql :top_foo_bar
      @tree.children.last.value_x.should eql :top_baz
    end

    def _against_lines heredoc_string

      _line_a = if heredoc_string
        heredoc_string.split line_split_regex
      else
        Home_::EMPTY_A_
      end
      @lines = Home_::Common_::Stream.via_nonsparse_array _line_a

      build_tree
      NIL_
    end

    def build_tree

      _oes_p = handle_event_selectively_

      @tree = subject_module_.via(
        :indented_line_stream, @lines,
        :build_using, handle_build,
        :glyph, '+ ',
        & _oes_p )

      NIL_
    end

    attr_reader :handle_build

    def _to_normal_string

      io = Home_.lib_.string_IO
      @tree.children_depth_first_via_args_hook io, nil do |node, io_, indent, p|
        io_.write "#{ indent }+ #{ node.value_x }"
        p[ -> do
          [ io_, "#{ indent }  " ]
        end ]
      end
      io.string
    end

    def _dedent s
      s.gsub! dedent_regex, Home_::EMPTY_S_
      s
    end

    memoize_ :dedent_regex do
      /^[ ]{8}/
    end

    memoize_ :line_split_regex do
      /(?<=\n)/
    end
  end
end
