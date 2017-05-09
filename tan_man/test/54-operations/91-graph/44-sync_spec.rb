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
    use :expect_CLI_or_API
    use :operations

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
        expect :error, :non_one_IO do |ev|
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

        expect_these_lines_in_array_ _actual do |y|
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
        expect :error, :input_parse_error do |ev|
          a.push ev
        end

        a.push execute
      end
    end

# (3/N)
    it "case 5 (a regressive case) - copy hereput to output", wip: true do

      out_a = [ 'gets removed' ]

      same_bytes = "digraph{\n  # a coment\n  foo -> bar\n}\n"

      call_API :graph, :sync,
        :hereput_string, same_bytes,
        :output_path, out_a

      expect_OK_event :wrote_resource

      out_a.join( EMPTY_S_ ).should eql same_bytes
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
        expect(
          :error, :hereput_and_output_waypoints_are_the_same,
        )

        a.push execute
      end
    end

# (5/N)
    it "case 3 (a regressive case) - write input to output thru transient graph ", wip: true do

      out_a = []
      call_API :graph, :sync,
        :input_string, "digraph {\n  x [ label=\"EX\" ]\n y -> z\np->q\n}\n",
        :output_path, out_a

      expect_OK_event :created_node
      expect_OK_event :created_association
      expect_OK_event :created_association
      expect_OK_event :wrote_resource
      expect_succeed
    end

# (6/N)
    it "case 3 - corner case 1 - this. (covers immaculate conception)", wip: true do

      out_a = []
      call_API :graph, :sync,
        :input_string, "digraph{\n hi->mother\n }",
        :output_path, out_a

      expect_OK_event :created_association
      expect_OK_event :wrote_resource

      out_a.join( EMPTY_S_ ).should eql "digraph{\nhi -> mother\n}\n"  # note spacing
    end

# (7/N)
    it "case 2 (\"import\") - simple venn case with edges only, no labels", wip: true do

      i_am_this =
        [ "digraph {\n", "  beebo -> ceebo\n", "  deebo -> feebo\n", "}\n" ]

      call_API :graph, :sync,
        :input_path,
          [ "digraph {\n", "abo -> beebo\n", "beebo -> ceebo\n", "}" ],
        :hereput_path,
          i_am_this

      expect_OK_event :created_association
      expect_OK_event :found_existing_association
      expect_OK_event :wrote_resource
      expect_succeed

      ( i_am_this * EMPTY_S_ ).should eql <<-HERE.unindent
        digraph {
          abo -> beebo
          beebo -> ceebo
          deebo -> feebo
        }
      HERE

      # (dig that smart indenting)
    end

# (8/N)
    it "case 1 - input will not overwrite labels, but will write them", wip: true do

      _input_s = "digraph{ \n su [ label=\"Super-Par\" ]\n ab [  label=\"Xy\"] \n}"

      _hereput_s = <<-HERE.unindent
        digraph{
         # hehe
          be [ label=\"Bee\" ]
          su [ label=\"Super Par\" thing=ding ]
        }
      HERE

      output_s = ""

      call_API :graph, :sync,
        :input_string, _input_s,
        :hereput_string, _hereput_s,
        :output_string, output_s

      expect_OK_event :found_existing_node
      expect_OK_event :created_node
      expect_OK_event :wrote_resource

      st = TestSupport_::Expect_Line::Scanner.via_string output_s
      st.next_line.should eql "digraph{\n"
      st.next_line.should eql " # hehe\n"
      st.next_line.should eql "  be [ label=\"Bee\" ]\n"

      st.next_line.should eql "  su [ label=\"Super Par\" thing=ding ]\n"
        # note that the label stayed the same

      st.next_line.should eql "ab [label=Xy]\n"
        # note that internally it decided to remove the quotes. also,
        # indentation is borked

      st.next_line.should eql "}\n"
      st.next_line.should be_nil
    end

    def _fails_commonly
      _x = _tuple.last
      _x.nil? || fail
    end

    def _subject_action
      [ :graph, :sync ]
    end

    def expression_agent_for_expect_emission
      black_and_white_expression_agent_for_expect_emission  # BE CAREFUL
    end
  end
end
