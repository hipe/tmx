require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - meaning", wip: true do

    TS_[ self ]
    use :operations

# (1/N)
    it "add - shell-style, after, in between - spacing mimics greatest lesser neighbor" do
      s = "digraph{}\n # cutie : patootey\n  # fazinkle: doo-dinkle\n"
      insert_foo_bar_into s
      s.should eql( <<-O.unindent )
      digraph{}
       # cutie : patootey
        # fazinkle: doo-dinkle
        #      foo: bar
      O
      expect_succeed
    end

# (2/N)
    it "add - C-style, before, before" do
      s = " /* winterly : wanterly \n bliff blaff */ digraph{}"
      insert_foo_bar_into s
      s.should eql " /* winterly : wanterly \n         foo : bar\n bliff blaff */ digraph{}"
      expect_succeed
    end

# (3/N)
    it "add - C-style, inside, after" do
      s = "digraph{ /* dolan : is \n a : duck \n */ }"
      insert_foo_bar_into s
      s.should eql "digraph{ /* dolan : is \n a : duck \nfoo : bar\n */ }"
      expect_succeed
    end

# (4/N)
    it "add - shell-style, inside, after" do

      s = <<-O.unindent
        # bifd : x

        digraph {

          # biff : baz

        }
        # zeff: baz
      O

      insert_foo_bar_into s

      scn = TestSupport_::Expect_Line::Scanner.via_string s
      scn.advance_N_lines 4
      scn.next_line.should eql "  # biff : baz\n"
      scn.next_line.should eql "  #  foo : bar\n"
    end

# (5/N)
    it "add to string with one space" do
      s = 'digraph{ }'
      insert_foo_bar_into s
      s.should eql "digraph{ # foo : bar\n}"
      expect_succeed
    end

# (6/N)
    it "add will not clobber" do
      s = "digraph{ # foo : x\n}"
      insert_foo_bar_into s
      expect_not_OK_event :name_collision,
        'cannot set (lbl "foo") to (val "bar"), it is already set to (val "x")'
      expect_fail
    end

    def insert_foo_bar_into s
      call_API :meaning, :add, :input_string, s, :output_string, s, :name, 'foo', :value, 'bar'
    end

# (7/N)
    it "add one before one - HERE HAVE A COMMA (this was hard) BUT IT IS MAGIC" do
                                  # client.parser.root = :node_stmt
      graph = _parse_string <<-O.unindent
        digraph {
          barl [label=barl]
        }
      O

      stmt = graph.to_node_statement_stream.gets.stmt
      alist = stmt.attr_list.content
      alist.class.should eql Home_::Models_::DotFile::Sexps::AList  # meh
      alist.prototype_ = graph.class.parse :a_list, 'a=b, c=d'
      alist.unparse.should eql( 'label=barl' )
      alist.prototype_.unparse.should eql( 'a=b, c=d' )
      alist._insert_assignment :fontname, 'Futura'
      alist.unparse.should eql('fontname=Futura, label=barl')
    end

# (8/N)
    it "UPDATE ONE AND ADD ONE -- WHAT WILL HAPPEN!!?? - note order logic" do

      graph = _parse_string <<-O.unindent
        digraph {
          barl [label=barl, fillcolor="too"]
        }
      O

      stmt = graph.to_node_statement_stream.gets.stmt
      alist = stmt.attr_list.content
      alist.unparse.should eql( 'label=barl, fillcolor="too"' )
      attrs = [['fontname', 'Futura'], ['fillcolor', '#11c11']]
      alist._update_attributes attrs
      alist.unparse.should eql(
        'fontname=Futura, label=barl, fillcolor="#11c11"'  )
    end

    def _parse_string s

      _bruh = TS_.lib_ :models_dot_file
      _bruh.client_class__.new.parse_string s
    end

# (9/N)
    it "OMG associate" do

      _input_string = <<-O.unindent
        digraph{
        # done : style=filled fillcolor="#79f234"
        fizzle [label=fizzle]
        sickle [label=sickle]
        fizzle -> sickle
        }
      O

      output_string = ""

      call_API :meaning, :associate,
        :meaning_name, 'done',
        :node_label, 'fizzle',
        :input_string, _input_string,
        :output_string, output_string

      _em = expect_OK_event :updated_attributes

      expect_succeed

      black_and_white( _em.cached_event_value ).should eql(
        "on node 'fizzle' added attributes: [ style=filled, fillcolor=#79f234 ]" )

      scn = TestSupport_::Expect_Line::Scanner.via_string output_string
      scn.advance_N_lines 2
      scn.next_line.should eql "fizzle [fillcolor=\"#79f234\", label=fizzle, style=filled]\n"
    end

    ignore_these_events :wrote_resource

  end
end
