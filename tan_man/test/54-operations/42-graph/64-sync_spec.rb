require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  # the three booleans (input, hereput, output) together have 8 permutations:
  #
  # case 1  Y Y Y  normal
  # case 2  Y Y    here as out, normal
  # case 3  Y      error - no output
  # case 4  Y   Y  transient, normal
  # case 5    Y Y  write hereput to output
  # case 6    Y    error - no input, no output
  # case 7      Y  error - no output
  # case 8         error - no input, no output

  describe "[tm] operations - graph - sync" do

    TS_[ self ]
    use :operations

    it "case 8 - error: no input, no output" do  #  indirectly case 3, case 6, case 7 too
      call_API :graph, :sync
      expect_not_OK_event :non_one_IO, /\Aneed exactly 1 input-related /i
      expect_not_OK_event :non_one_IO, /\Aneed exactly 1 output-related /i
      expect_failed
    end

    it "case 4 with input syntax failure" do

      out_a = EMPTY_A_
      call_API :graph, :sync,
        :input_string, "wazoozle\n",
        :output_path, out_a

      _em = expect_not_OK_event :input_parse_error

      black_and_white( _em.cached_event_value ).should eql(
        "expecting opening digraph line (e.g \"digraph{\") #{
          }near line 1: \"wazoozle\\n\"" )

      expect_failed
    end

    it "case 5 (a regressive case) - copy hereput to output" do

      out_a = [ 'gets removed' ]

      same_bytes = "digraph{\n  # a coment\n  foo -> bar\n}\n"

      call_API :graph, :sync,
        :hereput_string, same_bytes,
        :output_path, out_a

      expect_OK_event :wrote_resource

      out_a.join( EMPTY_S_ ).should eql same_bytes
    end

    it "case 5 - you can't copy a graph to the same waypoint" do

      same_path = Home_::TestSupport::FixtureGraphs[ :the_empty_graph ]
      same_path_ = same_path.dup

      call_API :graph, :sync,
        :hereput_path, same_path,
        :output_path, same_path_

      expect_not_OK_event :hereput_and_output_waypoints_are_the_same
      expect_failed
    end

    it "case 4 (a regressive case) - write input to output thru transient graph " do

      out_a = []
      call_API :graph, :sync,
        :input_string, "digraph {\n  x [ label=\"EX\" ]\n y -> z\np->q\n}\n",
        :output_path, out_a

      expect_OK_event :created_node
      expect_OK_event :created_association
      expect_OK_event :created_association
      expect_OK_event :wrote_resource
      expect_succeeded
    end

    it "case 4 - corner case 1 - this. (covers immaculate conception)" do

      out_a = []
      call_API :graph, :sync,
        :input_string, "digraph{\n hi->mother\n }",
        :output_path, out_a

      expect_OK_event :created_association
      expect_OK_event :wrote_resource

      out_a.join( EMPTY_S_ ).should eql "digraph{\nhi -> mother\n}\n"  # note spacing
    end

    it "case 2 (\"import\") - simple venn case with edges only, no labels" do

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
      expect_succeeded

      ( i_am_this * EMPTY_S_ ).should eql <<-HERE.unindent
        digraph {
          abo -> beebo
          beebo -> ceebo
          deebo -> feebo
        }
      HERE

      # (dig that smart indenting)
    end

    it "case 1 - input will not overwrite labels, but will write them" do

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

    ignore_these_events :using_parser_files

    def expression_agent_for_expect_event
      black_and_white_expression_agent_for_expect_event  # BE CAREFUL
    end
  end
end
