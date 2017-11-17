require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - association create" do

    TS_[ self ]
    use :memoizer_methods
    use :want_CLI_or_API
    use :models_association

# (1/N)

    # (a test of "ping" was removed #history-A.1)

# (2/N)

    context "when input cannot be resolved because none provided" do

      # :#cov2.6

      it "fails" do
        _fails
      end

      it "explains (offers suggestions)" do

        ev, ev_ = _tuple[0, 2]
        a = black_and_white_lines ev
        a.concat black_and_white_lines ev_

        want_these_lines_in_array_ a do |y|
          y << "needed exactly 1 input-related argument, had 0"
          y << "(provide 'input-string', 'input-path' or 'workspace-path')"
          y << "needed exactly 1 output-related argument, had 0"
          y << "(provide 'output-string', 'output-path' or 'workspace-path')"
        end
      end

      shared_subject :_tuple do

        call_API(
          * _subject_action,
          :from_node_label, "A",
          :to_node_label, "B",
        )
        a = []
        2.times do
          want :error, :non_one_IO do |ev|
            a.push ev
          end
        end
        a.push execute
      end
    end

# (3/N)
    context "associates nodes when neither exists, creating them" do

      # (before #history-A.1 this had an ugly fix for [#086])

      it "succeeds" do
        _succeeds
      end

      it "event for wrote resource (digraph)" do
        ev = _tuple[-2]
        ev.byte_downstream_reference || fail
        ev.bytes.zero? && fail
      end

      it "events for created node (2)" do
        ev, ev_ = _tuple[ 1, 2 ]
        black_and_white( ev ) == 'created node "one"' || fail
        black_and_white( ev_ ) == 'created node "two"' || fail
      end

      it "events for created association" do
        _actual = black_and_white _tuple[3]
        _actual == "created association: one -> two" || fail
      end

      it "content" do
        _actual = string_of_excerpted_lines_of_output_( -4..-1 )
        _expected = <<-O.unindent
          one [label=one]
          two [label=two]
          one -> two
          }
        O
        _actual == _expected || fail
      end

      shared_subject :_tuple do

        call_API_for_associate_ "one", "two"

        a = [ release_output_string_ ]

        2.times do
          want :info, :created_node do |ev|
            a.push ev
          end
        end

        want :info, :created_association do |ev|
          a.push ev
        end

        want :success, :wrote_resource do |ev|  # check this 1x only in file
          a.push ev
        end

        a.push execute
      end

      def digraph_file_path_
        _FILE_A
      end
    end

# (4/N)
    context "associates when first exists, second does not" do

      it "succeeds" do
        _succeeds
      end

      it "this emission about found existing node" do
        _actual = black_and_white _tuple[1]
        _actual == 'found existing node "alpha"' || fail
      end

      it "content" do
        _actual = string_of_excerpted_lines_of_output_( -4..-2 )
        _expected = <<-O.unindent
          alpha [label=alpha]
          peanut [label="peanut gallery"]
          alpha -> peanut
        O
        _actual == _expected || fail
      end

      shared_subject :_tuple do

        call_API_for_associate_ "alpha", "peanut gallery"
        a = [ release_output_string_ ]
        want( :info, :found_existing_node ) { |ev| a.push ev }
        want :info, :created_node
        want :info, :created_association
        _want_emission_for_wrote_resource
        a.push execute
      end

      def digraph_file_path_
        _FILE_B
      end
    end

# (5/N)
    context "does not associate again redundantly" do

      # :#cov2.7

      it "the result is a new kind of structure" do
        sct = _tuple.last
        sct.did_write && fail
        sct.user_value.HELLO_ASSOCIATION
      end

      it "the last emission says so" do
        _actual = black_and_white _tuple.first
        _actual == "found existing association: alpha -> gamma" || fail
      end

      shared_subject :_tuple do

        a = []
        call_API_for_associate_ "alpha", "gamma"

        _want_emissions_for_found_existing_nodes

        want :info, :found_existing_association do |ev|
          a.push ev  # offest 0
        end

        a.push execute
      end

      def digraph_file_path_
        _FILE_C
      end
    end

# (6/N)
    context "adds edge statements in unobtrusive lexical-esque order, #{
           } with taxonomy and proximity" do

      it "succeeds" do
        _succeeds
      end

      it "content" do
        _actual = string_of_excerpted_lines_of_output_( -8..-2 )
        _expected = <<-O.unindent
          */
          feasly [label=feasly]
          teasly [label=teasly]
          beasly -> teasly
          feasly -> teasly
          gargoyle -> flargoyle
          ainsly -> fainsly
        O
        _actual == _expected || fail
      end

      shared_subject :_tuple do

        call_API_for_associate_ "feasly", "teasly"
        a = [ release_output_string_ ]
        _want_emissions_for_created_all
        a.push execute
      end

      def digraph_file_path_
        _FILE_D
      end
    end

# (7/N)
    context 'uses any edge prototype called "edge_stmt"' do

      it "succeeds" do
        _succeeds
      end

      it "content" do
        _actual = string_of_excerpted_lines_of_output_( -2..-2 )
        _actual.should eql(
         "foo -> bar [ penwidth = 5 fontsize = 28 fontcolor = \"black\" label = \"e\" ]\n" )
      end

      shared_subject :_tuple do
        call_API_for_associate_ "foo", "bar's mother"
        a = [ release_output_string_ ]
        _want_emissions_for_created_all
        a.push execute
      end

      def digraph_file_path_
        _FILE_E
      end
    end

# (8/N)
    context "association prototype not found" do

      it "fails" do
        _fails
      end

      it "explains" do
        _actual = black_and_white _tuple[0]
        _actual == "the stmt_list has no prototype named 'clancy'" || fail
      end

      shared_subject :_tuple do
        a = []
        call_API_for_associate_ "a", "b", :prototype, :clancy
        _want_emissions_for_created_nodes
        want( :error, :association_prototype_not_found ) { |ev| a.push ev }
        a.push execute
      end

      def digraph_file_path_
        _FILE_F
      end
    end

# (9/N)
    context "lets you choose which of several edge prototypes" do

      it "content" do
        _actual = string_of_excerpted_lines_of_output_( -7..-2 )
        _expected = <<-O.unindent
          a [label=a]
          b [label=b]
          c [label=c]
          d [label=d]
          b -> a [this=is not=fancy]
          c -> d [this=style is=fancy]
        O
        _actual == _expected || fail
      end

      shared_subject :_tuple do

        # (this is a rough sketch proof of concept..)

        a = [ nil ]

        call_by do |p|

          with_feature_branch_for_associations_ do |ob|

            ob.touch_association_by_ do |o|
              o.from_and_to_labels "c", "d"
              o.prototype_name_symbol = :fancy
              o.listener = p
            end

            ob.touch_association_by_ do |o|
              o.from_and_to_labels "b", "a"
              o.prototype_name_symbol = :boring
              o.listener = p
            end

            ob._digraph_controller.graph_sexp.unparse
          end
        end

        2.times { _want_emission_for_created_all_no_write }

        a[ 0 ] = execute
        a
      end

      def digraph_file_path_
        _FILE_F
      end
    end

# (10/N)
    context "lets you set attributes in the edge prototype (alphabeticesque)" do

      it "succeeds" do
        _succeeds
      end

      it "content" do

        _expected = <<-O.unindent
          a -> b [ penwidth = 5 fontsize = 28 fontcolor = "black" label = "joe's mom: \\"jane\\"" ]
        O
        _actual = string_of_excerpted_lines_of_output_( -2..-2 )
        _actual == _expected || fail
      end

      shared_subject :_tuple do

        call_API_for_associate_ "a", "b", :attrs, { label: %<joe's mom: "jane"> }

        a = [ release_output_string_ ]

        _want_emissions_for_created_all

        a.push execute
      end

      def digraph_file_path_
        _FILE_G
      end
    end

# (11/N)
    context "lets you set attributes not yet in the edge prototype" do

      it "succeeds" do
        _succeeds
      end

      it "content" do
        _these = string_of_excerpted_lines_of_output_( -2..-2 )
        _expected = <<-O.unindent
          a -> b [ penwidth = 5 fontsize = 28 fontcolor = "black" label = "e" politics = radical ]
        O
        _these == _expected || fail
      end

      shared_subject :_tuple do

        call_API_for_associate_ "a", "b", :attrs, { politics: :radical }

        a = [ release_output_string_ ]

        _want_emissions_for_created_all

        a.push execute
      end

      def digraph_file_path_
        _FILE_G
      end
    end

# (12/N)
    context "against a digraph with two nodes, will first match existing nodes fuzzily before creating (FUZZY IS TURNED OFF FOR NOW)" do

      it "succeeds" do
        _succeeds
      end

      it "content" do
        _actual = string_of_excerpted_lines_of_output_ 3..3
        _actual == "  foo -> bar}\n" || fail
      end

      shared_subject :_tuple do

      s = <<-HERE.unindent
        digraph {
          bar [label=bar]
          foo [label=foo]}
      HERE

        false and [  # (the below was was used before #history-A.1)
        :from_node_label, 'fo',
        :to_node_label, 'ba',
        ]
        call_API(
          * _subject_action,
          # YIKES
          :from_node_label, 'foo',
          :to_node_label, 'bar',
        :input_string, s,
        :output_string, s
        )
        a = [ s ]

        _want_emissions_for_found_existing_nodes
        _want_emission_for_created_association
        _want_emission_for_wrote_resource

        a.push execute
      end
    end

    # -- assertions

    def _fails
      _tuple.last.nil? || fail
    end

    def _succeeds
      wrote = _tuple.last
      wrote.user_value.HELLO_ASSOCIATION
      wrote.bytes.zero? and fail
      NIL
    end

    # -- setup

    def _want_emissions_for_created_all  # 1x
      _want_emission_for_created_all_no_write
      want :success, :wrote_resource
      NIL
    end

    def _want_emission_for_created_all_no_write
      _want_emissions_for_created_nodes
      _want_emission_for_created_association
    end

    def _want_emission_for_created_association
      want :info, :created_association
    end

    def _want_emissions_for_created_nodes

      2.times { want :info, :created_node }
    end

    def _want_emissions_for_found_existing_nodes  # 1x
      2.times do
        want :info, :found_existing_node
      end
      NIL
    end

    def _want_emission_for_wrote_resource
      want :success, :wrote_resource
    end

    def call_API_for_associate_ from_s, to_s, * xtra

      s = ""
      @YIKES_OUTPUT_STRING = s

      _input_path = digraph_file_path_

      call_API(
        * _subject_action,
        :from_node_label, from_s,
        :to_node_label, to_s,
        :input_path, _input_path,
        :output_string, @YIKES_OUTPUT_STRING,
        * xtra,
      )

      NIL
    end

    def release_output_string_
      remove_instance_variable :@YIKES_OUTPUT_STRING
    end

    def _FILE_G
      fixture_file_ "point-5-1-prototype.dot"
    end

    def _FILE_F
      fixture_file_ "point-5-2-named-prototypes.dot"
    end

    def _FILE_E
      fixture_file_ "point-5-1-prototype.dot"
    end

    def _FILE_D
      fixture_file_ "0-nodes-3-edges.dot"
    end

    def _FILE_C
      fixture_file_ "2-nodes-1-edge.dot"
    end

    def _FILE_B
      fixture_file_ "2-nodes-0-edges.dot"
    end

    def _FILE_A
      fixture_file_ "../fixture-dot-files-for-node/simple-prototype-and-graph-with/zero-but-with-leading-space.dot"
    end

    def _subject_action
      [ :association, :add ]
    end
  end
end
# :#history-A.1 fully modernize style duing ween off [br]-era
