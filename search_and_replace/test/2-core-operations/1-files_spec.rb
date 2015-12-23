require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] S & R - reactive nodes - files" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :operations

    context "ask for a not found interface node from root" do

      call_by_ do
        call_ :ziffo
      end

      it "result value is failure result" do
        fails_
      end

      it "emission" do

        only_emission.should ( be_emission :error, :uninterpretable_token do | ev |

          _ = ' paths | path | filename_patterns | filename_pattern '

          black_and_white( ev ).should be_include _
        end )
      end
    end

    context "ask for subject (take defaults, go one past the end)" do

      call_by_ do
        call_ :search, :files_by_find, :wazooza
      end

      it "fails" do
        fails_
      end

      it "emission" do

        _ = :request_had_unexpected_argument
        only_emission.should ( be_emission_ending_with _ do |y|
          y.should eql [ 'unexpected argument (ick :wazooza)' ]
        end )
      end
    end

    context "as for subject (intentionally give empty arys for dootilyhahs)" do

      call_by_ do
        call_(
          :paths, EMPTY_A_,
          :filename_patterns, EMPTY_A_,
          :search, :files_by_find,
        )
      end

      it "fails" do
        fails_
      end

      it "emission says .." do

        _em = last_emission.should be_emission_ending_with :uninterpretable_token

        black_and_white( _em.cached_event_value ).should match(
          %r(\bto search you must have some paths\b)i )
      end
    end

    context "see the files matched by the find command" do

      call_by_ do
        _path = TS_._COMMON_DIR

        call_(
          :path, _path,
          :filename_pattern, '*-line*.txt',
          :search, :files_by_find,
        )
      end

      it "emits the find command" do

        last_emission.should be_emission( :info, :event, :find_command_args )
      end

      it "result is a stream of the matched files" do

        st = result_value_
        _ = st.gets
        __ = st.gets
        st.gets.should be_nil

        basename_( _ ).should eql 'one-line.txt'
        basename_( __ ).should eql _THREE_LINES_FILE
      end
    end

    context "see the files matched by grep", wip: true do

      call_by_ do
        _path = TS_._COMMON_DIR
        call_(
          :ruby_regexp, /\bwazoozle\b/i,
          :path, _path,
          :filename_pattern, '*-line*.txt',
          :search,
          :files_by_grep,
        )
      end

      it "emits the find command (again)" do

        _SOME_emission.should be_emission_ending_with( :find_command_args )
      end

      it "emits the grep command" do

        second_emission_.should ( be_emission :info, :grep_command do |ev|

          black_and_white( ev ).should eql 'lala'
        end )

        expect_no_emissions_after_index_ 1
      end

      it "result is a stream of the matched files" do

        st = result_value_
        _ = st.gets
        st.gets.should be_nil
        basename_( _ ).should eql _THREE_LINES_FILE
      end
    end
  end
end
