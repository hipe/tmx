require_relative '../../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - hear - meaning - apply" do

    TS_[ self ]
    use :memoizer_methods
    use :operations  # for #here1
    use :want_CLI_or_API

# (1/N)

    # #tombstone (very likely temporary): test was pending. now in other file.

# (2/N)
    context do
    it "associate meaning" do
        __succeeds
      end

      shared_subject :_tuple do

      s = <<-HERE.unindent
        digraph{
          # done: style=filled
          foo [label="foo"]
        }
      HERE

      call_API(
          * the_subject_action_for_hear_,
          :words, %w( foo is done ),
        :input_string, s,
        :output_string, s )

        want :info, :updated_attributes
        a = [ s ]
        a.push execute
      end

      it "(content)" do
        _actual = string_of_excerpted_lines_of_output_ 2..2  # :#here1
        _actual == "  foo [label=\"foo\", style=filled]\n"
      end
    end

    def __succeeds  # similar to but different from sibling: different type of entity
      sct = _tuple.last
      sct.did_write || fail
      sct.user_value.HELLO_NODE
    end

    ignore_these_events :wrote_resource

    # ==
    # ==
  end
end
