require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] stream - compound stream" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_module || fail
    end

    context "empty is empty" do

      it "builds" do
        _builds
      end

      it "is empty" do
        _subject.gets && fail
      end

      shared_subject :_subject do
        _subject_module.define do |o|
          NOTHING_  # hi.
        end
      end
    end

    context "two items via proc that makes stream" do

      it "builds" do
        _builds
      end

      it "BOO BAH" do
        st = _subject
        st.gets == :A || fail
        st.gets == :B || fail
        st.gets && fail
        st.gets && fail
      end

      it "you can use the familar stream methods (\"RISC\")" do
        _guy = _rebuild
        _act = _guy.to_a
        _act == %i( A B ) || fail
      end

      shared_subject :_subject do
        _rebuild
      end

      def _rebuild
        _subject_module.define do |o|
          o.add_stream_by do
            _build_minimal_stream_with_these :A, :B
          end
        end
      end
    end

    context "no tail call recursion so.." do

      it "builds" do
        _builds
      end

      it "boo bah" do
        st = _subject
        _x = st.gets
        _y = st.gets
        _y && fail
        _x == :loshenko || fail
      end

      shared_subject :_subject do
        _subject_module.define do |o|
          o.add_stream Home_::THE_EMPTY_MINIMAL_STREAM
          o.add_stream Home_::THE_EMPTY_MINIMAL_STREAM
          o.add_stream Home_::THE_EMPTY_MINIMAL_STREAM
          o.add_item :loshenko
        end
      end
    end

    # -- assert

    def _builds
      _subject || fail
    end

    # -- setup

    def _build_minimal_stream_with_these * sym_a
      symbol_stack = sym_a.reverse
      Home_::MinimalStream.by do
        symbol_stack.pop
      end
    end

    def _subject_module
      Home_::Stream::CompoundStream
    end
  end
end
