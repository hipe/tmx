require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - meaning - add" do

    TS_[ self ]
    use :memoizer_methods
    use :want_CLI_or_API
    use :models_meaning

    # (formatting in this file is currently jagged in the interest of preserving legacy for now)

# (1/N)
    context do

    it "add - shell-style, after, in between - spacing mimics greatest lesser neighbor" do
        _succeeds
      end

      shared_subject :tuple_ do
      s = "digraph{}\n # cutie : patootey\n  # fazinkle: doo-dinkle\n"
      insert_foo_bar_into s
      end

      it "(content)" do
        _content <<-O.unindent
      digraph{}
       # cutie : patootey
        # fazinkle: doo-dinkle
        #      foo: bar
      O
      end
    end

# (2/N)
    context do
    it "add - C-style, before, before" do
        _succeeds
      end

      it "(content)" do
        _content " /* winterly : wanterly \n         foo : bar\n bliff blaff */ digraph{}"
      end

      shared_subject :tuple_ do
      s = " /* winterly : wanterly \n bliff blaff */ digraph{}"
      insert_foo_bar_into s
      end
    end

# (3/N)
    context do
    it "add - C-style, inside, after" do
        _succeeds
      end

      it "(content)" do
        _content "digraph{ /* dolan : is \n a : duck \nfoo : bar\n */ }"
      end

      shared_subject :tuple_ do
      s = "digraph{ /* dolan : is \n a : duck \n */ }"
      insert_foo_bar_into s
      end
    end

# (4/N)
    context do
    it "add - shell-style, inside, after" do
        _succeeds
      end

      shared_subject :tuple_ do
      s = <<-O.unindent
        # bifd : x

        digraph {

          # biff : baz

        }
        # zeff: baz
      O

      insert_foo_bar_into s
      end

      it "(content (partial))" do

      scn = TestSupport_::Want_Line::Scanner.via_string s
      scn.advance_N_lines 4
        want_these_lines_in_array_with_trailing_newlines_ scn do |y|
          y << "  # biff : baz"
          y << "  #  foo : bar"
          y << nil  # experiment: quit early
        end
      end
    end

# (5/N)
    context do
    it "add to string with one space" do
        _succeeds
      end

      it "(content)" do
        _content "digraph{ # foo : bar\n}"
      end

      shared_subject :tuple_ do
      s = 'digraph{ }'
      insert_foo_bar_into s
      end
    end

# (6/N)
    context "add will not clobber" do

      it "fails" do
        _fails
      end

      it "emission.." do
        _actual = black_and_white _tuple.first
        _actual == 'cannot set "foo" to "bar". it is already set to "x"' || fail
      end

      shared_subject :_tuple do

      s = "digraph{ # foo : x\n}"

        s.freeze  # (tacitly asserts that selfsame string is not mutated)
        call_API_for_add_meaning_ s

        a = []
        want :error, :name_collision do |ev|
          a.push ev
        end
        a.push execute
      end
    end

    alias_method :_succeeds, :want_result_from_add_is_entity__
    alias_method :_content, :want_content_from_add_is__

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
      attrs = {
        fontname: "Futura",
        fillcolor: "#11c11",
      }  # before #history-A.1 the above was a 2-D array (2 element tuples)
      alist.update_attributes_ attrs
      alist.unparse.should eql(
        'fontname=Futura, label=barl, fillcolor="#11c11"'  )
    end

    def _parse_string s

      _client = TS_::Models::Dot_File.PARSER_INSTANCE
      _client.parse_string s
    end

    def _fails
      _x = _tuple.last
      _x.nil? || false
    end

    # ==
    # ==

  end
end
# #tombstone-A.2: the point at which one test moved to a new file
# :#history-A.1 (can be temporary) (as referenced)
