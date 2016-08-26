require_relative 'test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] operations - permute", wip: true do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    # use :doc_test

    shared_subject :_shared_state do

      X_O_Permute_Struct = ::Struct.new :out_string, :err_string, :result
      o = X_O_Permute_Struct.new

      grp = __build_spy_group
      _st = __build_permutation_stream

      call_API :permute,
        :test_file, fixture_file__( 'some_speg.rb' ),
        :permutations, _st,
        :stdout, grp[ :o ],
        :stderr, grp[ :e ]

      o.out_string, o.err_string = grp.flush_to_strings_for :o, :e
      o.result = @result
      o
    end

    it "results in a success value" do

      _shared_state.result.should eql true
    end

    it "adds new test cases to the document" do

      _rx = /\b(?<num_added>\d+) case\(s\) added\b/

      _md = _shared_state.err_string.should match _rx

      _md[ :num_added ].to_i.should eql 3
    end

    it "expresses that it skipped generating a test that existed already" do

      _rx = /\b(?<num_skipped>\d+) already done\b/

      _md = _shared_state.err_string.should match _rx

      _md[ :num_skipped ].to_i.should eql 1
    end

    it "the output string is correct byte-per-byte" do

      _exp = <<-HERE.unindent
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
    end

    def __build_spy_group
      grp = Home_::IO.spy.group.new
      grp.debug_IO = debug_IO
      grp.do_debug_proc = -> { do_debug }
      grp.add_stream :o
      grp.add_stream :e
      grp
    end

    define_method :__build_permutation_stream, -> do

      _Struct = ( Lazy_.call do
        ::Struct.new :A, :B
      end )

      -> do
        struct = _Struct[]
        a = []
        a.push struct.new( :one, :three )
        a.push struct.new( :two, :three )
        a.push struct.new( :one, :four )
        a.push struct.new( :two, :four )
        Common_::Stream.via_nonsparse_array a
      end
    end.call

    def subject_API
      Home_::API
    end
  end
end
