require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] [..] run stream via comment block" do

    TS_[ self ]
    use :memoizer_methods
    use :embedded_line_collections
    use :runs

    # (possibly like its sibling, this one stays tightly to this file:)

    in_file do
      full_path_ 'doc/issues/021-what-are-runs.md'
    end

    context "(first example)" do

      shared_subject :_a do
        _for %r(\bthis simple example\z)
      end

      it "(builds)" do
        _a or fail
      end

      context "(discussion run)" do

        it "has discussion run, is 3 lines long (#coverpoint1.1)" do
          run = _run
          run.category_symbol == :discussion or fail
          run.number_of_lines___ == 3 or fail
        end

        it "this discussion run is lossless" do

          _exp = <<-HERE.unindent
            # hi i'm discussion line A
            # hi i'm discussion line B
            #
          HERE

          _assemble_string == _exp or fail
        end

        def _run
          _a.fetch 0
        end
      end

      context "(code run)" do

        it "has code run, is 1 line long" do
          run = _run
          run.category_symbol == :code or fail
          run.number_of_lines___ == 1 or fail
        end

        it "code run is lossless" do

          _assemble_string == "#     1 + 1  # => 2\n" or fail
        end

        def _run
          _a.fetch 1
        end
      end

      def _assemble_string
        _run.to_line_object_stream.join_into "" do |o|
          o.string
        end
      end

      context "(general)" do

        it "has no other runs" do
          _a.length == 2 or fail
        end
      end
    end

    context "(this second example) (#coverpoint1.2)" do

      shared_subject :_a do
        _for %r(\bas it does in this example\b)
      end

      it "builds, is 2 runs in length" do
        _a.length == 2 or fail
      end

      it "(disc run)" do
        at_index_expect_cat_sym_and_num_lines_ 0, :discussion, 3
      end

      it "(code run)" do
        at_index_expect_cat_sym_and_num_lines_ 1, :code, 1
      end
    end

    context "(this final example) (#coverpoint1.3)" do

      shared_subject :_a do
        x = _for %r(\bas in this example\b)
        _ELC_close_if_necessary  # NOTE only while you're sure it's the last one!
        x
      end

      it "builds" do
        _a
      end

      it "(disc / code / disc)" do
        at_index_expect_cat_sym_and_num_lines_ 0, :discussion, 1
        at_index_expect_cat_sym_and_num_lines_ 1, :code, 1
        at_index_expect_cat_sym_and_num_lines_ 2, :discussion, 1
      end
    end

    alias_method :_for, :run_array_via_regex_
  end
end
# history: this is a rename-and-cleanup of another test file numbered "66"
