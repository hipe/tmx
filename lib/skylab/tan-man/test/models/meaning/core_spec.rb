require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Meaning

  describe "[tm] Models::Meaning core" do

    extend TS_

    it "add - shell-style, after, in between - spacing mimics greatest lesser neighbor" do
      s = "digraph{}\n # cutie : patootey\n  # fazinkle: doo-dinkle\n"
      insert_foo_bar_into s
      s.should eql( <<-O.unindent )
      digraph{}
       # cutie : patootey
        # fazinkle: doo-dinkle
        #      foo: bar
      O
      expect_succeeded
    end

    it "add - C-style, before, before" do
      s = " /* winterly : wanterly \n bliff blaff */ digraph{}"
      insert_foo_bar_into s
      s.should eql " /* winterly : wanterly \n         foo : bar\n bliff blaff */ digraph{}"
      expect_succeeded
    end

    it "add - C-style, inside, after" do
      s = "digraph{ /* dolan : is \n a : duck \n */ }"
      insert_foo_bar_into s
      s.should eql "digraph{ /* dolan : is \n a : duck \nfoo : bar\n */ }"
      expect_succeeded
    end

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

    it "add to string with one space" do
      s = 'digraph{ }'
      insert_foo_bar_into s
      s.should eql "digraph{ # foo : bar\n}"
      expect_succeeded
    end

    it "add will not clobber" do
      s = "digraph{ # foo : x\n}"
      insert_foo_bar_into s
      expect_not_OK_event :name_collision,
        'cannot set (lbl "foo") to (val "bar"), it is already set to (val "x")'
      expect_failed
    end

    def insert_foo_bar_into s
      call_API :meaning, :add, :input_string, s, :output_string, s, :name, 'foo', :value, 'bar'
    end

    it "list when input string has parsable lines" do

      call_API :meaning, :ls, :input_string, "digraph{/* foo : fee \n fiffle: faffle */}"

      expect_no_events
      st = @result

      ent = st.gets
        ent.property_value_via_symbol( :name ).should eql 'foo'
        ent.property_value_via_symbol( :value ).should eql 'fee '

      ent = st.gets
        ent.property_value_via_symbol( :name ).should eql 'fiffle'
        ent.property_value_via_symbol( :value ).should eql 'faffle */'  # <- LOOK

      st.gets.should be_nil

    end

    it "add one before one - HERE HAVE A COMMA (this was hard) BUT IT IS MAGIC", wip: true do
                                  # client.parser.root = :node_stmt
      graph = client.parse_string <<-O.unindent
        digraph {
          barl [label=barl]
        }
      O

      stmt = graph.node_statements.first
      alist = stmt.attr_list.content
      alist.class.should eql( TanMan_::Models::DotFile::Sexps::AList ) # meh
      alist._prototype = graph.class.parse :a_list, 'a=b, c=d'
      alist.unparse.should eql( 'label=barl' )
      alist._prototype.unparse.should eql( 'a=b, c=d' )
      alist._insert_assignment :fontname, 'Futura'
      alist.unparse.should eql('fontname=Futura, label=barl')
    end

    it "UPDATE ONE AND ADD ONE -- WHAT WILL HAPPEN!!?? - note order logic", wip: true do

      graph = client.parse_string <<-O.unindent
        digraph {
          barl [label=barl, fillcolor="too"]
        }
      O

      stmt = graph.node_statements.first
      alist = stmt.attr_list.content
      alist.unparse.should eql( 'label=barl, fillcolor="too"' )
      attrs = [['fontname', 'Futura'], ['fillcolor', '#11c11']]
      alist._update_attributes attrs
      alist.unparse.should eql(
        'fontname=Futura, label=barl, fillcolor="#11c11"'  )
    end
  end
end
