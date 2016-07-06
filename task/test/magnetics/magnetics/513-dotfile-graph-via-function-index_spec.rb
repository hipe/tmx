require_relative '../../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics - magnetics - dotfile graph via function index" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics
    use :magnetics_dotfile_graph

    # NOTE as for the following test: we are doing this only to lock down
    # the existing behavior. the only significance of this "test" in its
    # current form is the concert of (A) that we touched #cp1-1, #cp1-2,
    # #cp1-3, #cp1-4, #cp1-5 and #cp1-6 while generating this and that (B)
    # the output passed careful visual inspection when rendered thru
    # graph-viz.
    #
    # the extent to which we will break the subject "test" down into more
    # reasonable, granular tests is determined entirely by the extent to
    # which this work survives integration, practical application and
    # maintenance.
    #
    # that is, if (by some miracle) the subject function proves useful
    # exacly as-is then we don't want to burn time on the considerable
    # (and perhaps absurd) effort involved in parsing the dotfile to
    # verify its content.
    #
    # however, do NOT be afraid to scrap this whole "test" for something
    # more content-oriented if ever that seems prudent.
    #
    # (and note that at writing we are parsing the whole dotfile anyway,
    # an act which itself does some tacit assertion.)

    context '(big coverer)' do

      shared_subject :_dfg_reflection do

        dotfile_graph_reflection_via_(
          %w(unique product via one of one),
          %w(other unique product via one of two and two of two),
          %w(third unique product and other guy via one of two and two of two),
          %w(common product via one of one),
          %w(common product via one of two and two of two),
          %w(other common product and thing via one of one),
          %w(other common product and thing via one of two and two of two),
        )
      end

      it "builds" do
        _dfg_reflection || fail
      end

      it "EEK every byte (see comments here)" do

        _actual_s = _dfg_reflection.ONE_BIG_STRING

        _expected_s = <<-HERE.unindent
          digraph g {
            unique_product -> one_of_one [label="comes from"]
            other_unique_product -> one_of_two [label="depends on"]
            other_unique_product -> two_of_two [label="depends on"]
            third_unique_product -> _f2 [label="comes from"]
            other_guy -> _f2 [label="comes from"]
            common_product -> _oot1
            _oot1 -> one_of_one
            _oot1 -> _aot1
            _aot1 -> one_of_two
            _aot1 -> two_of_two
            other_common_product -> _oot2
            _oot2 -> one_of_one
            _oot2 -> _f6
            thing -> _oot3
            _oot3 -> one_of_one
            _oot3 -> _f6
            _oot1 [label="(one of these)"]
            _oot2 [label="(one of these)"]
            _oot3 [label="(one of these)"]
            _aot1 [label="(all of these)"]
            _f2 -> one_of_two
            _f2 -> two_of_two
            _f6 -> one_of_two
            _f6 -> two_of_two
            _f2 [label="(all of these)"]
            _f6 [label="(all of these)"]
            one_of_one [label="one of\\none"]
            unique_product [label="unique\\nproduct"]
            other_unique_product [label="other unique\\nproduct"]
            one_of_two [label="one of\\ntwo"]
            two_of_two [label="two of\\ntwo"]
            third_unique_product [label="third unique\\nproduct"]
            other_guy [label="other\\nguy"]
            common_product [label="common\\nproduct"]
            other_common_product [label="other common\\nproduct"]
            thing [label="thing"]
          }
        HERE

        _actual_s == _expected_s || fail
      end
    end
  end
end
# #history: rewrote over many more granular tests
