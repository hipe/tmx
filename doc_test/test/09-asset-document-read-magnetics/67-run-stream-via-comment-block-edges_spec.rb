require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] [..] run stream via comment block (edges)" do

    TS_[ self ]
    use :memoizer_methods
    use :embedded_line_collections
    use :runs

    in_file do
      full_path_ 'doc/issues/023-run-edge-cases.md'
    end

    context "(#coverpoint1-4)" do

      shared_subject :_a do
        _for %r(\bindent can decrease in a discussion like so\z)
      end

      it "builds, 2 runs" do
        _a.length == 2 or fail
      end

      it "(etc)" do
        at_index_expect_cat_sym_and_num_lines_ 0, :discussion, 2
        at_index_expect_cat_sym_and_num_lines_ 1, :code, 1
      end
    end

    context "(#coverpoint1-5)" do

      shared_subject :_a do
        _for %r(\btransition back to discussion\z)
      end

      it "builds, 3 runs" do
        _a.length == 3 or fail
      end

      it "(etc)" do
        at_index_expect_cat_sym_and_num_lines_ 0, :discussion, 1
        at_index_expect_cat_sym_and_num_lines_ 1, :code, 1
        at_index_expect_cat_sym_and_num_lines_ 2, :discussion, 1
      end
    end

    context "(#coverpoint1-6)" do

      shared_subject :_a do
        _for %r(\bblank lines in a code run get added to that code run\z)
      end

      it "builds, 2 runs" do
        _a.length == 2 or fail
      end

      it "(etc)" do
        at_index_expect_cat_sym_and_num_lines_ 0, :discussion, 1
        at_index_expect_cat_sym_and_num_lines_ 1, :code, 3
      end
    end

    context "(#coverpoint1-7)" do

      shared_subject :_a do
        _for %r(\btransition back to discussion while reducing margin\z)
      end

      it "builds, 3 runs" do
        _a.length == 3 or fail
      end

      it "(etc)" do
        at_index_expect_cat_sym_and_num_lines_ 0, :discussion, 1
        at_index_expect_cat_sym_and_num_lines_ 1, :code, 1
        at_index_expect_cat_sym_and_num_lines_ 2, :discussion, 1
      end
    end

    context "(#coverpoint1-8)" do

      shared_subject :_a do
        _for %r(\bwhatever this is\z)
      end

      it "builds, 3 runs" do
        _a.length == 3 or fail
      end

      it "(etc)" do
        at_index_expect_cat_sym_and_num_lines_ 0, :discussion, 1
        at_index_expect_cat_sym_and_num_lines_ 1, :code, 1
        at_index_expect_cat_sym_and_num_lines_ 2, :discussion, 1
      end
    end

    context "(#coverpoint1-9)" do

      shared_subject :_a do
        x = _for %r(\bwhen all comment lines are blank\z)
        _ELC_close_if_necessary
        x
      end

      it "builds, 1 run" do
        _a.length == 1 or fail
      end

      it "discussion only" do
        at_index_expect_cat_sym_and_num_lines_ 0, :discussion, 2
      end
    end

    alias_method :_for, :run_array_via_regex_
  end
end
# history: this is a rename-and-cleanup of another test file numbered "66"
