require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - node collection - digraph" do

    TS_[ self ]
    use :memoizer_methods
    use :want_emission_fail_early  # <- oooOOOooh

    context "when no nodes of interest in upstream" do

      it "produces an empty graph" do

        want_these_lines_in_array_ _these.last do |y|
          y << _open_digraph_line
          y << _style_line
          y << _close_digraph_line
        end
      end

      it "expresses that none of the nodes are doc nodes" do

        _these.first == [ "none of the 3 nodes in the collection are doc nodes." ] || fail
      end

      shared_subject :_these do

        expressed_lines = nil ; produced_lines = []

        call(
          :node_collection, :digraph,
          :byte_downstream, produced_lines,
          :upstream_reference, Fixture_file_[ :rochambeaux_mani ],
        )

        want :info, :expression do |y|
          expressed_lines = y
        end

        want_result ACHIEVED_

        [ expressed_lines, produced_lines ]
      end
    end

    context "when some nodes of interest in upstream" do

      it "OK" do

        want_these_lines_in_array_ _these.last do |y|

          y << _open_digraph_line

          y << _style_line

          y << %q(  5 [label="i said\n\"hi\"\n[#005]"])"\n"

          y << %q(  4 [label="some\ntopic\na-\>b\n[#004]"])"\n"

          y << "  5->4\n"

          y << _close_digraph_line
        end
      end

      shared_subject :_these do

        produced_lines = []

        call(
          :node_collection, :digraph,
          :byte_downstream, produced_lines,
          :upstream_reference, Fixture_file_[ :for_digraph_simple_mani ],
        )

        want_result ACHIEVED_

        [ produced_lines ]
      end
    end

    def _open_digraph_line
      "digraph {\n"
    end

    def _style_line
      /\A  node \[fillcolor=/
    end

    def _close_digraph_line
      "}\n"
    end

    def expression_agent
      API_expag_[]
    end
  end
end
