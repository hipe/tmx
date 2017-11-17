require_relative '../../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - hear - meaning - create" do

    TS_[ self ]
    use :memoizer_methods
    use :operations
    use :want_CLI_or_API

# (1/N)
    context do
    it "`foo means bar` assigns a heretofor unknown meaning (OMG OMG OMG)" do
        _succeeds
      end

      shared_subject :_tuple do

        _up_s = <<-O.unindent
        digraph {
          # biff : baz
        }
      O

      s = ""
      call_API(
        * the_subject_action_for_hear_,
          :words, %w( foo means bar ),
          :input_string, _up_s,
          :output_string, s,
      )
        a = [ s ]
        a.push execute
        a
      end  # _tuple

      it "(content)" do
        _actual = _tuple.first
      _exp = <<-O.unindent
        digraph {
          # biff : baz
          #  foo : bar
        }
      O
        _actual == _exp || fail
      end
    end  # context

# (2/N)
    context do  # :#cov3.3
    it "assign a known meaning to a new value" do
        _succeeds
      end

      shared_subject :_tuple do

        _s = <<-O.unindent
        digraph {
          # success : red
        }
      O

        s = ""
      call_API(
          * the_subject_action_for_hear_,
          :words, %w( success means blue ),
          :input_string, _s,
          :output_string, s,
      )
        a = [ s ]
        a.push execute
        a
      end

      it "(content)" do

      _exp = <<-O.unindent
        digraph {
          # success : blue
        }
      O

        _tuple.first == _exp || fail
      end
    end

    def _succeeds
      sct = _tuple.last
      sct.did_write || fail
      sct.user_value.HELLO_MEANING
    end

    ignore_these_events :wrote_resource

    # ==
    # ==
  end
end
