require_relative 'test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] permute" do

    TS_[ self ]
    Zerk_test_support_[]::API[ self ]

    context "ping" do

      call_by do
        call :ping  # (result is state)
      end

      it "works" do

        _be_this = be_emission :info, :expression, :ping do |y|
          y == ['ping from permute.'] || fail
        end

        first_emission.should _be_this
      end
    end

    context "money" do

      call_by do
        _path = fixture_file__ 'some_speg.kode'
        _st = __build_permutation_stream
        _ = call(
          :permute,
          :test_file, _path,
          :permutations, _st,
        )
        _
      end

    it "adds new test cases to the document" do

      _rx = /\b(?<num_added>\d+) case\(s\) added\b/

        _md = _rx.match _the_line
        _md[ :num_added ].to_i.should eql 3
      end

    it "expresses that it skipped generating a test that existed already" do

      _rx = /\b(?<num_skipped>\d+) already done\b/

        _md = _rx.match _the_line
        _md[ :num_skipped ].to_i == 1 || fail
      end

      shared_subject :_the_line do

        lines = nil
        first_emission.should( be_emission( :info, :expression, :summary ) do |y|
          lines = y
        end )
        lines.fetch 0
      end

    it "the output string is correct byte-per-byte" do

      same = "::Kernel._WRITE_ME"

      _exp = <<-HERE.unindent
        # etc 1

          it "zeep deep - foozazi" do
            # etc
          end

          it "two, three" do
            #{ same }
          end

          it "one, four" do
            #{ same }
          end

          it "two, four" do
            #{ same }
          end

            it "one, three - already done (and deeper indent)" do
            end

        # etc 2
      HERE

        lib = Home_::Want_Line
        _actual_st = root_ACS_state.result
        _exp_st = Home_.lib_.basic::String::LineStream_via_String[ _exp ]

        lib::Streams_have_same_content[ _actual_st, _exp_st, self ]
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
    end

    def subject_API
      Home_::Permute::API
    end
  end
end
