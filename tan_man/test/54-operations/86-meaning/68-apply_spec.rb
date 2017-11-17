require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - meaning - apply" do

    TS_[ self ]
    use :memoizer_methods
    use :want_CLI_or_API
    use :models_meaning

    context "(success)" do

      it "succeeds" do  # :#cov3.2
        did_write = _tuple.fetch 2
        did_write.bytes == 149 || fail  # or whatever
        did_write.user_value.HELLO_NODE
      end

      it "emits" do
        _actual = black_and_white _tuple.fetch 1
        _actual == 'on node "fizzle" added attributes: [ style=filled, fillcolor=#79f234 ]' || fail
      end

      it "content" do
        _s = _tuple.fetch 0
        scn = TestSupport_::Want_Line::Scanner.via_string _s
        scn.advance_N_lines 2
        _actual = scn.gets
        _actual == "fizzle [fillcolor=\"#79f234\", label=fizzle, style=filled]\n" || fail
      end

      shared_subject :_tuple do

        _input_string = <<-O.unindent
          digraph{
          # done : style=filled fillcolor="#79f234"
          fizzle [label=fizzle]
          sickle [label=sickle]
          fizzle -> sickle
          }
        O

        s = ""
        a = [s]

        call_API(
          * _subject_action,
          :meaning_name, "done",
          :node_label, "fizzle",
          :input_string, _input_string,
          :output_string, s,
        )

        want :info, :updated_attributes do |ev|
          a.push ev
        end

        want :success, :wrote_resource

        a.push execute
      end
    end

    def _subject_action
      [ :meaning, :apply ]
    end

    # ==
    # ==
  end
end
# #history-A: first test abstracted from sibling test file (for "add")
