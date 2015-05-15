require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] doc-test - [ actions ] - permute" do

    extend TS_
    use :expect_event

    it "adds new test cases, skips existing, magnetic, maintains formatting" do

      grp = __build_spy_group
      _st = __build_permutation_stream

      call_API :permute,
        :test_file, Fixture_file_[ 'some_speg.rb' ],
        :permutations, _st,
        :stdout, grp[ :o ],
        :stderr, grp[ :e ]

      out_s, err_s = grp.flush_to_strings_for :o, :e

      out_s.should eql <<-HERE.unindent
        # etc 1

          it "zeep deep - foozazi" do
            # etc
          end

          it "two, three" do
            self._COVER_ME
          end

          it "one, four" do
            self._COVER_ME
          end

          it "two, four" do
            self._COVER_ME
          end

            it "one, three - already done (and deeper indent)" do
            end

        # etc 2
      HERE

      err_s.should eql "(3 case(s) added, 1 already done)\n"

      expect_succeeded
    end

    def __build_spy_group
      grp = TestSupport_::IO.spy.group.new
      grp.debug_IO = debug_IO
      grp.do_debug_proc = -> { do_debug }
      grp.add_stream :o
      grp.add_stream :e
      grp
    end

    define_method :__build_permutation_stream, -> do

      _Struct = ( Callback_.memoize do
        ::Struct.new :A, :B
      end )

      -> do
        struct = _Struct[]
        a = []
        a.push struct.new( :one, :three )
        a.push struct.new( :two, :three )
        a.push struct.new( :one, :four )
        a.push struct.new( :two, :four )
        Callback_::Stream.via_nonsparse_array a
      end
    end.call
  end
end
