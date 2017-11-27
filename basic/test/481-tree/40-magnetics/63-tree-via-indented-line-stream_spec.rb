require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - magnetics - via indented line stream" do

    TS_[ self ]
    use :want_event
    use :tree

    it "none" do
      _against_lines nil
      want_no_events
      expect( @tree ).to be_nil
    end

    it "one" do
      _against_lines _dedent <<-HERE
        + beeble
      HERE
      expect( @tree.value ).to be_nil
      expect( @tree.parent ).to be_nil
      expect( @tree.children_count ).to eql 1
      tree = @tree.children.first
      expect( tree.value ).to eql "beeble\n"
      expect( tree.parent.object_id ).to eql @tree.object_id
      expect( tree.children_count ).to be_zero
      expect( tree.children ).to be_nil
      want_no_events
    end

    it "when a line does not have the glyph" do

      _against_lines _dedent <<-HERE
        hi + no
      HERE

      expect( @tree ).to eql false

      want_not_OK_event_ :line_does_not_have_glyph

      want_no_more_events
    end

    it "two in a row at the same level" do
      _against_lines _dedent <<-HERE
         + foo
         + bar
      HERE
      expect( @tree.children_count ).to eql 2
      expect( @tree.children.length ).to eql 2
      o, x = @tree.children
      expect( o.value ).to eql "foo\n"
      expect( x.value ).to eql "bar\n"
      expect( o.parent.object_id ).to eql x.parent.object_id
      expect( o.parent.object_id ).to eql @tree.object_id
      expect( o.children_count ).to be_zero
      expect( x.children_count ).to be_zero
      expect( o.children ).to be_nil
      expect( x.children ).to be_nil
    end

    it "strange de-indent" do
      _against_lines _dedent <<-HERE
          + foo
         + bar
      HERE
      expect( @tree ).to eql false
      want_not_OK_event :invalid_dedent
      want_no_more_events
    end

    it "one child" do
      _against_lines _dedent <<-HERE
          + foo
              + bar
      HERE
      expect( @tree.children_count ).to eql 1
      o = @tree.children.first
      expect( o.children_count ).to eql 1
      x = o.children.first
      expect( x.children_count ).to be_zero
      expect( x.value ).to eql "bar\n"
    end

    it "step back two" do
      _against_lines _dedent <<-HERE
          + foo
            + bar
              + baz
          + boffo
      HERE
      expect( _to_normal_string ).to eql _dedent <<-O
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
      expect( _to_normal_string ).to eql omg
      want_no_events
    end

    it "`build_using` allows you to map the received string values to whatever" do
      @handle_build = -> line, parent do
        if parent.parent
          :"#{ parent.value }_#{ line.chop! }"
        else
          :"top_#{ line.chop! }"
        end
      end
      _against_lines _dedent <<-O
        + foo
          + bar
        + baz
      O
      expect( @tree.children.first.value ).to eql :top_foo
      expect( @tree.children.first.children.first.value ).to eql :top_foo_bar
      expect( @tree.children.last.value ).to eql :top_baz
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

      _p = handle_event_selectively_

      @tree = subject_module_.via(
        :indented_line_stream, @lines,
        :build_using, handle_build,
        :glyph, '+ ',
        & _p )

      NIL_
    end

    attr_reader :handle_build

    def _to_normal_string

      io = Home_.lib_.string_IO
      @tree.children_depth_first_via_args_hook io, nil do |node, io_, indent, p|
        io_.write "#{ indent }+ #{ node.value }"
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
