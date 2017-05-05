require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - meaning - list" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_CLI_or_API
    use :models_meaning

# (1/N)
    context "C-style" do

      it "each item of this stream is (at the surface) the same object (flyweight)" do

        a = _matrix
        a.length > 1 || fail
        a.first || fail  # be sure that any one item is not nil/false
        _these = a.map( & :object_id_of_item ).uniq
        _these.length == 1 || fail
      end

      it "NOTE the trailing space in the item value is preserved" do

        item = _matrix.fetch 0
        item.natural_key_string == "foo" || fail
        item.value_string == "fee " || fail
      end

      it "NOTE even the close comment sequence is include (BUG)" do

        a = _matrix
        a.length == 2 || fail  # we should test this somewhere
        item = a.fetch 1
        item.natural_key_string == "fiffle" || fail
        item.value_string == "faffle */" || fail  # <-- LOOK
      end

      shared_subject :_matrix do
        _matrix_via_input_string "digraph{/* foo : fee \n fiffle: faffle */}"
      end
    end

# (2/N)
    context "shell-style" do

      _input_string = <<-O.unindent
        digraph {
          # money : honey
          # funny : bunny
        }
      O

      it "ok great (note how this style doesn't have the same issues as C-style)" do
        a = _matrix
        item = a.fetch 0
        item.natural_key_string == "money" || fail
        item.value_string == "honey" || fail
        item = a.fetch 1
        item.natural_key_string == "funny" || fail
        item.value_string == "bunny" || fail
        a.length == 2 || fail
      end

      shared_subject :_matrix do
        _matrix_via_input_string _input_string
      end
    end

# (3/N)
    it "when input does not parse as a graph-viz dotfile (it borks)"

    # -- setup

    def _matrix_via_input_string input_s

      call_API(
        :meaning, :ls,  # _subject_action
        :input_string, input_s,
      )

      # (note no expectation of any emissions - so if something emits, fails)

      _st = execute
      matrix_of_item_snapshots_via_meaning_stream_ _st
    end

    # ==
    # ==
  end
end
