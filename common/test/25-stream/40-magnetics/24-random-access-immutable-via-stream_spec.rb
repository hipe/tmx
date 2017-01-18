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
        _subject || fail
      end

      it "access first then last" do
        bx = _subject
        bx[ :A ] == "A" || fail
        bx[ :C ] == "C" || fail
      end

      it "access last then first (exercises cache) " do
        bx = _rebuild
        bx[ :C ] == "C" || fail
        bx[ :A ] == "A" || fail
      end

      it "ask for offset of already indexed" do
        bx = _rebuild
        bx[ :A ]
        bx.offset_of( :A ) == 0 || fail
      end

      it "ask for offset of not yet indexed" do
        _bx = _rebuild
        _bx.offset_of( :C ) == 2 || fail
      end

      it "ask for offset of doesn't exist when not yet cached" do
        _bx = _rebuild
        _bx.offset_of( :D ).nil? || fail
      end

      it "ask for offset of doesn't exist when cached" do
        bx = _rebuild
        bx[ :C ]
        bx.offset_of( :D ).nil? || fail
      end

      it "to value stream before cached" do
        _bx = _rebuild
        _st = _bx.to_value_stream
        _st.to_a == %w( A B C ) || fail
      end

      it "to value stream when cached midway" do
        bx = _rebuild
        bx[ :A ]
        _st = bx.to_value_stream
        _st.to_a == %w( A B C ) || fail
      end

      it "to value stream after cached" do
        bx = _rebuild
        bx[ :C ]
        _st = bx.to_value_stream
        _st.to_a == %w( A B C ) || fail
      end

      shared_subject :_subject do
        _rebuild
      end

      def _rebuild

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
  end
end
# #born years after its asset
