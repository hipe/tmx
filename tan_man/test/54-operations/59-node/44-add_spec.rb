require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - node create" do

    TS_[ self ]
    use :memoizer_methods
    use :want_CLI_or_API
    use :models_node

# (1/N)
    # (pinging this action is gone.)

# (2/N)
    context "add a minimal node to the minimal string" do

      it "result is the entity that was created (currently flyweight is used)" do
        _want_result_that_is_node_for :bae
      end

      it "content bytes are correct" do
        _want_content "digraph{bae [label=bae]}"
      end

      it "main event explains, reflects" do
        _want_event_for_created_node "bae"
      end

      shared_subject :_tuple do

        s = "digraph{}"
        a = [ s ]

        _mutate_string_by_adding_node s, 'bae'

        _want_common_events_and_execute a
      end
    end

# (3/N)
    context "add one before" do

      it "result.." do
        _want_result_that_is_node_for :bar
      end

      it "content.." do
        _want_content "digraph{ bar [label=bar]\nfoo [label=foo]\n}"
      end

      it "main event.." do
        _want_event_for_created_node "bar"
      end

      shared_subject :_tuple do

        s = "digraph{ foo [label=foo]\n}"
        a = [ s ]

        _mutate_string_by_adding_node s, "bar"

        _want_common_events_and_execute a
      end
    end

# (4/N)
    context "add one after" do

      it "result.." do
        _want_result_that_is_node_for :foo
      end

      it "content.." do
        _want_content "digraph{\n bar\nfoo [label=foo]}"
      end

      it "main event.." do
        _want_event_for_created_node "foo"
      end

      shared_subject :_tuple do

        s = "digraph{\n bar}"
        a = [ s ]

        _mutate_string_by_adding_node s, "foo"

        _want_common_events_and_execute a
      end
    end

# (5/N)
    context "add one same - fails with event about node with same name" do

      it "fails.." do
        _fails_commonly
      end

      it "main event.." do  # :#cov2.4

        ev = _main_event
        _actual = black_and_white ev
        ev.ok && fail
        ev.did_mutate_document && fail
        ev.component_association == Home_::Models_::Node || fail  # not important
      end

      shared_subject :_tuple do

        s = " digraph { zoz } "
        a = [ s ]

        _mutate_string_by_adding_node s, "zoz"

        want :error, :found_existing_node do |ev|
          a.push ev
        end

        a.push execute
      end
    end

# (6/N)
    context "add one in between" do

      it "result.." do
        _want_result_that_is_node_for :menengitis
      end

      it "content.." do
        _want_content " digraph { apple ; menengitis [label=menengitis] ; zoz ; } "
      end

      it "main event.." do
        _want_event_for_created_node "menengitis"
      end

      shared_subject :_tuple do

        s = " digraph { apple ; zoz ; } "
        a = [ s ]

        _mutate_string_by_adding_node s, "menengitis"

        _want_common_events_and_execute a
      end
    end

# (9/N)

    context "add a node to zero nodes" do

      it "number of nodes before is 0 and after is 1" do
        a = _tuple
        a.first.zero? || fail
        a[1] == 1 || fail
      end

      it "content" do
        _stmt_list = _tuple.last
        _actual = _stmt_list.unparse_into ""
        _actual == "feep [label=feep]\n" || fail
      end

      shared_subject :_tuple do

        with_feature_branch_for_nodes_ do
          a = []
          a.push all_nodes_right_now_count_
        touch_node_via_label 'feep'
          a.push all_nodes_right_now_count_  # kill get_node_array,
          a.push stmt_list
        end
      end

      def digraph_file_path_
        _use_file_zero
      end
    end

# (10/N)

    context "creates unique but natural node_ids" do

      it "labels" do
        _actual = _tuple.first
        want_these_lines_in_array_ _actual do |y|
          y << "MiLk the catfish"
          y << "milk the cat"
          y << "milk the cow"
        end
      end

      it "symbols (generated ID's)" do
        _actual = _tuple.last
        want_these_lines_in_array_ _actual do |y|
          y << :milk_3
          y << :milk_2
          y << :milk
        end
      end

      shared_subject :_tuple do

        with_feature_branch_for_nodes_ do

        touch_node_via_label 'milk the cow'
        touch_node_via_label 'milk the cat'
        touch_node_via_label 'MiLk the catfish'

          to_two_arrays__labels_and_symbols_
        end
      end

      def digraph_file_path_
        _use_file_zero
      end
    end

    -> do  # #here2

        exp = "html-escaping support is currently very limited - #{
          }the following characters are not yet supported: #{
           }#{ %s<"\t" (009), "\n" (010) and "\u007F" (127)> }"

# (11/N)

    context "incoming label strings are validated - #{
          }\"#{ exp[ 0..96 ] }[..]\"" do

      it "fails" do
        _tuple[1].nil? || fail
      end

      it "event (every byte of the message) (uses `sentence_phrase__`)" do

        yikes = _tuple.first
        ev_p = yikes.pop
        yikes == [ :error, :invalid_characters ] || fail
        _ev = ev_p[]
        _actual = black_and_white _ev
        _actual == exp || fail
      end

      shared_subject :_tuple do

        with_feature_branch_for_nodes_ do

          a = []

          _x = @OB_FOR_NODES.touch_node_via_label_ "\t\t\n\x7F" do |*i_a, &ev_p|
            i_a.push ev_p ; a.push i_a  # yikes
          end

          a.push _x
        end
      end

      def digraph_file_path_
        _use_file_watchya
      end
    end

    end.call  # :#here2

    -> do  # #here3

        input = 'joe\'s "mother" & i <wat>'
        output = 'joe&apos;s &quot;mother&quot; &amp; i &lt;wat&gt;'

# (12/N)

    context "it *will* escape *some* chars - this:(#{ input }) becomes : #{ output }" do

      it "um.." do

        _entity = _tuple.first
        _big_html_table = _entity.get_node_label_
        _big_html_table.include? output or fail
      end

      shared_subject :_tuple do

        with_feature_branch_for_nodes_ do

          o = touch_node_via_label input

          [ o ]
        end
      end

      def digraph_file_path_
        _use_file_watchya
      end
    end

    end.call  # :here3

    def _want_event_for_created_node label_s

      ev = _main_event
      _actual = black_and_white ev
      _expected = "created node \"#{ label_s }\""
      _actual == _expected || fail
      ev.node.get_node_label_ == label_s || fail
      ev.did_mutate_document || fail
      ev.ok || fail
    end

    def _want_common_events_and_execute a

      want :success, :created_node do |ev|
        a.push ev
      end

      want :success, :wrote_resource do |ev|
        a.push ev
      end

      a.push execute
    end

    def _want_content exp_s
      _actual = _tuple.fetch 0
      _actual == exp_s || fail
    end

    def _want_result_that_is_node_for sym
      _node = _result
      _node.node_identifier_symbol_ == sym || fail
    end

    def _fails_commonly
      _result.nil? || fail
    end

    def _main_event
      _tuple.fetch 1
    end

    def _result
      _tuple.last  # either 4th or 3rd element :/
    end

    # --

    def _mutate_string_by_adding_node s, name_s

      call_API(
        * _subject_action,
        :node_name, name_s,
        :input_string, s,
        :output_string, s,
      )
    end

    def _subject_action
      [ :node, :add ]
    end

    # --

    def _use_file_watchya
      fixture_file_ "big-ass-prototype-with-html-in-it-watchya-gonna-do-now-omg.dot"
    end

    def _use_file_zero
      fixture_file_ "simple-prototype-and-graph-with/zero.dot"
    end

    # ==
    # ==
  end
end
# #archive-A.2: archive ancient commented out tests: add to empty document [ with prototype ]
# #history-A: full rewrite
