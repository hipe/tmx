require_relative 'test-support'

module Skylab::Basic::TestSupport::Tree

  describe "[ba] tree - via indented line stream" do

    extend TS_

    Basic_::TestSupport::TestLib_::Expect_event[ self ]

    it "none" do
      with_lines nil
      expect_no_events
      @tree.should be_nil
    end

    it "one" do
      with_lines dedent <<-HERE
        + beeble
      HERE
      @tree.value_x.should be_nil
      @tree.parent.should be_nil
      @tree.child_count.should eql 1
      tree = @tree.children.first
      tree.value_x.should eql "beeble\n"
      tree.parent.object_id.should eql @tree.object_id
      tree.child_count.should be_zero
      tree.children.should be_nil
      expect_no_events
    end

    it "when a line does not have the glyph" do
      with_lines dedent <<-HERE
        hi + no
      HERE
      @tree.should eql false
      expect_not_OK_event :line_does_not_have_glyph
      expect_no_more_events
    end

    it "two in a row at the same level" do
      with_lines dedent <<-HERE
         + foo
         + bar
      HERE
      @tree.child_count.should eql 2
      @tree.children.length.should eql 2
      o, x = @tree.children
      o.value_x.should eql "foo\n"
      x.value_x.should eql "bar\n"
      o.parent.object_id.should eql x.parent.object_id
      o.parent.object_id.should eql @tree.object_id
      o.child_count.should be_zero
      x.child_count.should be_zero
      o.children.should be_nil
      x.children.should be_nil
    end

    it "strange de-indent" do
      with_lines dedent <<-HERE
          + foo
         + bar
      HERE
      @tree.should eql false
      expect_not_OK_event :invalid_dedent
      expect_no_more_events
    end

    it "one child" do
      with_lines dedent <<-HERE
          + foo
              + bar
      HERE
      @tree.child_count.should eql 1
      o = @tree.children.first
      o.child_count.should eql 1
      x = o.children.first
      x.child_count.should be_zero
      x.value_x.should eql "bar\n"
    end

    it "step back two" do
      with_lines dedent <<-HERE
          + foo
            + bar
              + baz
          + boffo
      HERE
      to_normal_string.should eql dedent <<-O
        + foo
          + bar
            + baz
        + boffo
      O
    end

    it "canonical complex case" do
      omg = dedent <<-HERE
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
      with_lines omg
      to_normal_string.should eql omg
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
      with_lines dedent <<-O
        + foo
          + bar
        + baz
      O
      @tree.children.first.value_x.should eql :top_foo
      @tree.children.first.children.first.value_x.should eql :top_foo_bar
      @tree.children.last.value_x.should eql :top_baz
    end

    def with_lines heredoc_string
      _line_a = if heredoc_string
        heredoc_string.split line_split_regex
      else
        Basic_::EMPTY_A_
      end
      @lines = Basic_::Callback_::Stream.via_nonsparse_array _line_a
      build_tree
      nil
    end

    def build_tree

      _oes_p = handle_event_selectively

      @tree = Subject_[].via(
        :indented_line_stream, @lines,
        :build_using, handle_build,
        :glyph, '+ ',
        :on_event_selectively, _oes_p )

      nil
    end

    attr_reader :handle_build

    def to_normal_string

      io = Basic_.lib_.string_IO
      @tree.children_depth_first_via_args_hook io, nil do |node, io_, indent, p|
        io_.write "#{ indent }+ #{ node.value_x }"
        p[ -> do
          [ io_, "#{ indent }  " ]
        end ]
      end
      io.string
    end

    def dedent s
      s.gsub! dedent_regex, Basic_::EMPTY_S_
      s
    end

    def self.memoize i, & p  # #todo
      p_ = -> do
        x = p[]
        p_ = -> { x }
        x
      end
      define_method i do
        p_[]
      end
    end

    memoize :dedent_regex do
      /^[ ]{8}/
    end

    memoize :line_split_regex do
      /(?<=\n)/
    end
  end
end
