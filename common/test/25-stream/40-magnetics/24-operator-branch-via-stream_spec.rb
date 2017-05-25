require_relative '../../test-support'

module Skylab::Common::TestSupport

  describe "[co] stream - magnetics - random access immutable via etc" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_module || fail
    end

    context "A B C" do

      it "builds" do

        _with_memoized
        @SUBJECT || fail
      end

      it "access first then last" do

        _with_memoized
        _expect_lookup_softly "A", :A
        _expect_lookup_softly "C", :C
      end

      it "access last then first (exercises cache) " do

        _with_rebuilt
        _expect_lookup_softly "C", :C
        _expect_lookup_softly "A", :A
      end

      it "ask for offset of already indexed" do

        _with_rebuilt
        _lookup_softly :A
        _expect_offset 0, :A
      end

      it "ask for offset of not yet indexed" do

        _with_rebuilt
        _expect_offset 2, :C
      end

      it "ask for offset of doesn't exist when not yet cached" do

        _with_rebuilt
        _expect_offset nil, :D
      end

      it "ask for offset of doesn't exist when cached" do

        _with_rebuilt
        _lookup_softly :C
        _expect_offset nil, :D
      end

      it "to value stream before cached" do

        _with_rebuilt
        _st = _to_value_stream
        _st.to_a == %w( A B C ) || fail
      end

      it "to value stream when cached midway" do

        _with_rebuilt
        _lookup_softly :A
        _st = _to_value_stream
        _st.to_a == %w( A B C ) || fail
      end

      it "to value stream after cached" do

        _with_rebuilt
        _lookup_softly :C
        _st = _to_value_stream
        _st.to_a == %w( A B C ) || fail
      end

      # --
      #
      # (NOTE - as an afterthought we have altered the above to insulate
      # it from the particular business names, when the subject was
      # retrofitted to accord to with operator branched. adhering to a
      # "rule of 2's" for future tests (if you use a business name more
      # than 2x, hide it behind a local method) might be good..)

      def _expect_offset x, sym

        _actual = @SUBJECT.offset_via_reference sym
        _actual == x || fail
      end

      def _to_value_stream
        @SUBJECT.to_dereferenced_item_stream
      end

      def _expect_lookup_softly x, sym
        _actual = _lookup_softly sym
        _actual == x || fail
      end

      def _lookup_softly sym
        @SUBJECT.lookup_softly sym
      end

      def _with_memoized
        @SUBJECT = _memoized_subject
        NIL
      end

      def _with_rebuilt
        @SUBJECT = _build
        NIL
      end

      shared_subject :_memoized_subject do
        _build
      end

      def _build

        stack = %w( C B A )
        _st = Home_::MinimalStream.by do
          stack.pop
        end

        _subject_module.define do |o|
          o.upstream = _st
          o.key_method_name = :intern
        end
      end
    end

    def _subject_module
      Home_::Stream::Magnetics::RandomAccessImmutable_via_Stream
    end

    # ==
    # ==
  end
end
# #pending-rename: with its asset
# #born years after its asset
