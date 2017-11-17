require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  # three booleans together have 8 permutations. our three booleans are
  # "input", "hereput" and "output". as it works out, the permutation is
  # valid IFF it has two or more of the three elements. (and otherwise (with
  # zero or one of the three elements), it is an invalid combination.)
  #
  # case 1:   input, hereput, output   good: write the new graph to the output
  # case 2:   input, hereput           good: output graph replaces the hereput graph
  # case 3:   input,          output   ok: write input graph as-is to the output
  # case 4:   input                    error: no output
  # case 5:          hereput, output   ok: write hereput graph as-is to the output
  # case 6:          hereput           error: no input, no output
  # case 7:                   output   error: no input
  # case 8:                            error: no input, no output
  #
  # :#spot1.2

  describe "[tm] operations - graph - sync" do

    TS_[ self ]
    use :memoizer_methods
    use :want_CLI_or_API
    use :operations
    use :operations_legacy_methods_for_emission

# (1/N)
    context "case 8 - error: no input, no output" do  # almost case 4, 6 & 7 too

      it "fails with nil" do

        _hi = _tuple.first
        _hi.nil? || fail
      end

      it "complains about missing BOTH input and output (first line)" do

        _tuple[1] == "missing required input- and output-related arguments" || fail
      end

      it 'suggests parameters you can use to provide those directions (note the use of "and/or")' do

        _tuple[2] == "use 'input-string', 'input-path', 'workspace-path', 'output-string' and/or 'output-path'" || fail
      end

      shared_subject :_tuple do

        call_API( * _subject_action )

        a = []
        event = nil
        want :error, :non_one_IO do |ev|
          event = ev
        end
        a.push execute

        _actual = black_and_white_lines event
        a.concat _actual
        a
      end
    end

# (2/N)
    context "case 3 with input syntax failure" do  # :#cov11.1

      it "fails with nil" do
        _fails_commonly
      end

      it "whined specifically" do

        _actual = black_and_white_lines _tuple.first

        want_these_lines_in_array_ _actual do |y|
          y << "expecting opening digraph line (e.g \"digraph{\") #{
            }near line 1: \"wazoozle\\n\""
        end
      end

      shared_subject :_tuple do

        call_API(
          * _subject_action,
        :input_string, "wazoozle\n",
        :output_path, EMPTY_A_,  # sneaky
        )

        a = []
        want :error, :input_parse_error do |ev|
          a.push ev
        end

        a.push execute
      end
    end

# (3/N)
    context "case 5 (a regressive case) - copy hereput to output" do

      it "for now, result is bytes written" do
        _succeeds
      end

      it "(content oh my)" do

        # (having sent as the `output_path` an array covers one small part of [ba])

        _expected_s, _actual_a = _tuple
        _actual_s = _actual_a.join EMPTY_S_
        _actual_s == _expected_s || fail
      end

      shared_subject :_tuple do

      out_a = [ 'gets removed' ]

      same_bytes = "digraph{\n  # a coment\n  foo -> bar\n}\n"

        call_API(
          * _subject_action,
        :hereput_string, same_bytes,
        :output_path, out_a
        )

        _want_wrote

        a = [ same_bytes ]
        a.push out_a
        a.push execute
        a
      end
    end

# (4/N)
    context "case 5 - you can't copy a graph to the same waypoint" do

      it "fails commonly, emits custom emission (for now with only channel, no content)" do
        _fails_commonly
      end

      shared_subject :_tuple do

        same_path = Home_::TestSupport::FixtureGraphs[ :the_empty_graph ]
        _same_path_ = same_path.dup

        call_API(
          * _subject_action,
          :hereput_path, same_path,
          :output_path, _same_path_,
        )

        a = []
        want(
          :error, :hereput_and_output_waypoints_are_the_same,
        )

        a.push execute
      end
    end

# (5/N)
    context "case 3 (a regressive case) - write input to output thru transient graph " do

      it "(events)" do
        _succeeds 37
      end

      it "(content (2 things))" do

        _actual_s = _tuple.first
        _actual = _actual_s.split %r(^)
        want_these_lines_in_array_with_trailing_newlines_ _actual do |y|
          y << "digraph{"
          y << "x [label=EX]"  # note quotes were removed
          y << "p -> q"  # note order was alphabetized
          y << "y -> z}"
        end
      end

      shared_subject :_tuple do

        s = ""
        call_API(
          * _subject_action,
        :input_string, "digraph {\n  x [ label=\"EX\" ]\n y -> z\np->q\n}\n",
          :output_string, s,
        )

      want_OK_event :created_node
      want_OK_event :created_association
      want_OK_event :created_association
        _want_wrote

        a = [s]
        a.push execute
      end
    end

# (6/N)
    context "case 3 - corner case 1 - this. (covers immaculate conception)" do

      it "(events)" do
        _succeeds
      end

      it "(content)" do

        _actual = _tuple.first
        _actual == "digraph{\nhi -> mother\n}\n" || fail  # note spacing
      end

      shared_subject :_tuple do

        s = ""
        call_API(
          * _subject_action,
        :input_string, "digraph{\n hi->mother\n }",
          :output_string, s,
        )

      want_OK_event :created_association
        _want_wrote

        a = [s]
        a.push execute
      end
    end

# (7/N)
    context "case 2 (\"import\") - simple venn case with edges only, no labels" do

      it "(emits)" do
        _succeeds
      end

      shared_subject :_tuple do

      i_am_this =
        [ "digraph {\n", "  beebo -> ceebo\n", "  deebo -> feebo\n", "}\n" ]

        call_API(
          * _subject_action,
        :input_path,
          [ "digraph {\n", "abo -> beebo\n", "beebo -> ceebo\n", "}" ],
        :hereput_path,
          i_am_this,
        )

      want_OK_event :created_association
      want_OK_event :found_existing_association
        _want_wrote

        a = [ i_am_this ]
        a.push execute
      end

      it "(content)" do

        _actual_a = _tuple.first
        _actual_s = _actual_a.join EMPTY_S_

        _expected = <<-HERE.unindent
        digraph {
          abo -> beebo
          beebo -> ceebo
          deebo -> feebo
        }
      HERE
      # (dig that smart indenting)

        _actual_s == _expected || fail
      end
    end

# (8/N)
    context "case 1 - input will not overwrite labels, but will write them (README)" do

      # in a fully parsimonious implementation, the elements of the input
      # document would (one could reasonably argue) overrule any competing
      # atomic element in the hereput document in cases of collision (for
      # definitions of) during the recursive merge.
      #
      # for example if you have two nodes with the same ID, the label from
      # the incoming node should clobber that of the existing node.
      #
      # HOWEVER for the case of labels, it seems that the legacy work avoided
      # clobbering these, but instead *ignored* the label in the input
      # document. perhaps the rationale was (and in any case is now)
      # that you might want to hand-edit your document to have a friendlier,
      # more interesting or more informational label.
      #
      # it might be better to make this some kind of option or at least emit
      # a notice that we are disregarding the labels in the input in such
      # cases, but for now we are just re-greening.. :#cov3.4

      it "(events)" do
        _succeeds
      end

      it "(content)" do

        _actual = _tuple.first

        _scn = Home_.lib_.basic::String::LineStream_via_String[ _actual ]

        want_these_lines_in_array_with_trailing_newlines_ _scn do |y|

          y << "digraph{"
          y << " # hehe"
          y << "  be [ label=\"Bee\" ]"

          y << "  su [ label=\"Super Par\" thing=ding ]"
            # note that the label stayed the same

          y << "ab [label=Xy]"
            # note that internally it decided to remove the quotes. also,
            # indentation is borked

          y << "}"
        end
      end

      shared_subject :_tuple do

      _input_s = "digraph{ \n su [ label=\"Super-Par\" ]\n ab [  label=\"Xy\"] \n}"

      _hereput_s = <<-HERE.unindent
        digraph{
         # hehe
          be [ label=\"Bee\" ]
          su [ label=\"Super Par\" thing=ding ]
        }
      HERE

      output_s = ""

        call_API(
          * _subject_action,
        :input_string, _input_s,
        :hereput_string, _hereput_s,
        :output_string, output_s
        )

      want_OK_event :found_existing_node
      want_OK_event :created_node
        _want_wrote

        a = [ output_s ]
        a.push execute
      end
    end

    # == assertions

    def _succeeds d=nil
      sct = _tuple.last
      if d
        sct.bytes == d || fail
      else
        sct.bytes.zero? && fail
      end
      sct.user_value._DO_WRITE_COLLECTION_ || fail  # or don't test this
    end

    def _fails_commonly
      _x = _tuple.last
      _x.nil? || fail
    end

    # == setup

    # ignore_these_events :wrote_resource  # <- keep this out - assert it explicitly

    def _want_wrote
      want :success, :wrote_resource
    end

    def _subject_action
      [ :graph, :sync ]
    end

    def expression_agent_for_want_emission
      black_and_white_expression_agent_for_want_emission  # BE CAREFUL
    end
  end
end
# #history-A.1: half rewrite during ween off [br]
