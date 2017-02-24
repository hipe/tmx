require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - node create", wip: true do

    TS_[ self ]
    use :models_node

    it "ping the 'node add' action" do
      call_API :node, :add, :ping
      expect_OK_event :ping_from_action, "ping from action - (ick :add)"
      @result.should eql :ping_from__add__
    end

    it "add a minimal node to the minimal string" do
      s = 'digraph{}'
      add_name_to_string 'bae', s
      expect_OK_event :created_node, 'created node (lbl "bae")'
      s.should eql 'digraph{bae [label=bae]}'
      expect_succeed
    end

    it "add one before" do
      s = "digraph{ foo [label=foo]\n}"
      add_name_to_string 'bar', s
      expect_OK_event :created_node, 'created node (lbl "bar")'
      s.should eql "digraph{ bar [label=bar]\nfoo [label=foo]\n}"
      expect_succeed
    end

    it "add one after" do
      s = "digraph{\n bar}"
      add_name_to_string 'foo', s
      expect_OK_event :created_node, 'created node (lbl "foo")'
      s.should eql "digraph{\n bar\nfoo [label=foo]}"
      expect_succeed
    end

    it "add one same - fails with event about node with same name" do
      s = " digraph { zoz } "
      add_name_to_string 'zoz', s
      expect_not_OK_event :found_existing_node, 'node already existed: (lbl "zoz")'
      expect_fail
    end

    it "add one in between" do
      s = " digraph { apple ; zoz ; } "
      add_name_to_string 'menengitis', s
      expect_OK_event :created_node do |ev|
        ev_ = ev.to_event
        a = ev_.members
        a.should be_include :ok
        a.should be_include :node_stmt
        ev_.node_stmt.label.should eql 'menengitis'
      end
      s.should eql " digraph { apple ; menengitis [label=menengitis] ; zoz ; } "
      expect_succeed
    end

    # it "to a empty 'digraph' -- makes up its own prototype" :+#ancient
    if false
      using_dotfile 'digraph{}'
      invoke_from_dotfile_dir 'graph', 'node', 'add', 'foo'
      dotfile_pathname.read.should eql( 'digraph{foo [label=foo]}' )
    end

    # it "to a digraph with a prototype - it adds that puppy"  :+#ancient
    if false
      using_dotfile <<-O.unindent
        digraph {
        /*
          example stmt_list:
            foo -> bar
            biff -> baz

          example node_stmt:
            foo [label=foo]
        */
        }
      O
      invoke_from_dotfile_dir 'graph', 'node', 'add', 'bar'
      output.lines.last.string.should match( /created node: bar/ )
      content = dotfile_pathname.read
      content.should be_include( 'bar [label=bar]' )
    end

    def add_name_to_string name_s, s
      call_API :node, :add, :name, name_s, :input_string, s, :output_string, s
    end

    using_input 'simple-prototype-and-graph-with/zero.dot' do

      it 'adds a node to zero nodes' do
        get_node_array.should eql EMPTY_A_
        touch_node_via_label 'feep'
        a = get_node_array
        a.length.should eql 1
        stmt_list.unparse.should eql "feep [label=feep]\n"
      end

      it "creates unique but natural node_ids" do

        touch_node_via_label 'milk the cow'
        touch_node_via_label 'milk the cat'
        touch_node_via_label 'MiLk the catfish'

        _sym_a = node_sexp_stream.map_by( & :node_id ).to_a
        _sym_a == %i( milk_3 milk_2 milk ) || fail

        a = node_sexp_stream.map_by( & :label ).to_a
        a.shift.should eql 'MiLk the catfish'
        a.shift.should eql 'milk the cat'
        a.shift.should eql 'milk the cow'
      end
    end

    using_input(
      "big-ass-prototype-with-html-in-it-watchya-gonna-do-now-omg.dot" ) do

      -> do
        exp = "html-escaping support is currently very limited - #{
          }the following characters are not yet supported: #{
           }#{ %s<"\t" (009), "\n" (010) and "\u007F" (127)> }"

        it "when you try to use weird chars for labels - #{
          }\"#{ exp[ 0..96 ] }[..]\"" do

          touch_node_via_label "\t\t\n\x7F"

          _em = expect_not_OK_event :invalid_characters

          black_and_white( _em.cached_event_value ).should eql exp

          expect_no_more_events
        end
      end.call

      -> do
        input = 'joe\'s "mother" & i <wat>'
        output = 'joe&apos;s &quot;mother&quot; &amp; i &lt;wat&gt;'

        it "it will escape some chars - #{
          }this:(#{ input }) becomes : #{ output }" do

          o = touch_node_via_label input
          big_html_string = o.unparse

          big_html_string.should be_include output
        end
      end.call
    end

    ignore_these_events :using_parser_files, :wrote_resource
  end
end
