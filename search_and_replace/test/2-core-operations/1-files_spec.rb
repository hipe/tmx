require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] core operations - (1) files", wip: true do

    TS_[ self ]
    use :my_API

    context "ask for a not found interface node from root" do

      call_by do
        call :ziffo
      end

      it "result value is failure result" do
        fails
      end

      it "emits alternation" do

        _be_this = be_emission_ending_with :no_such_association do |ev|

          _ = black_and_white ev

          _.should include_alternation_for_(
            %w( paths path filename_patterns filename_pattern ) )
        end

        only_emission.should _be_this
      end
    end

    context "ask for subject (take defaults, go one past the end)" do

      call_by do
        call :search, :files_by_find, :wazooza
      end

      it "fails" do
        fails
      end

      it "emits" do

        _ = :arguments_continued_past_end_of_phrase

        _be_this = be_emission_ending_with _ do |y|

          y.last.should be_include ' end of phrase - unexpected argument: \'wa'
        end

        only_emission.should _be_this
      end
    end

    context "as for subject (intentionally give empty arys for dootilyhahs)" do

      call_by do
        call(
          :paths, EMPTY_A_,
          :filename_patterns, EMPTY_A_,
          :search, :files_by_find,
        )
      end

      it "fails" do
        fails
      end

      it "emits multi-line emission" do

        _be_this = be_emission_ending_with :required_component_not_present do |y|
          y.fetch(0).should eql "'search' is not available because:"
          y.fetch(1).should eql "  • required component not present: 'paths'"
        end

        last_emission.should _be_this
      end
    end

    context "see the files matched by the find command" do

      call_by do

        call(
          :path, common_haystack_directory_,
          :filename_pattern, '*-line*.txt',
          :search, :files_by_find,
        )
      end

      it "emits the find command" do

        last_emission.should be_emission( :info, :event, :find_command_args )
      end

      it "result is a stream of the matched files" do

        st = root_ACS_result
        _ = st.gets
        __ = st.gets
        st.gets.should be_nil

        basename_( _ ).should eql 'one-line.txt'
        basename_( __ ).should eql _THREE_LINES_FILE
      end
    end

    context "unavailability.. (note we pass a nil ruby regexp explicitly)" do

      call_by do

        call(
          :ruby_regexp, nil,
          :path, common_haystack_directory_,
          :search,
          :files_by_grep,
        )
      end

      it "fails" do
        fails
      end

      it "emits non-contexutalized" do

        _be_this = be_emission_ending_with :required_component_not_present do |y|

          y.should eql [ "required component not present: 'ruby-regexp'" ]
        end

        last_emission.should _be_this
      end
    end

    context "see the files matched by grep" do

      call_by do

        state = call(
          :ruby_regexp, /\bwazoozle\b/i,
          :path, common_haystack_directory_,
          :filename_pattern, '*-line*.txt',
          :search,
          :files_by_grep,
        )

        st = state.result
        if st
          _x = st.gets
          _x_ = st.gets
          _x__ = st.gets
          st.upstream.release_resource
          state.to_state_with_customized_result [ _x, _x_, _x__ ]
        else
          state
        end
      end

      it "emits the grep command (sort of)" do

        last_emission.should be_emission_ending_with :grep_command_head
      end

      it "result is a stream of paths" do

        a = root_ACS_customized_result
        basename_( a.fetch 0 ).should eql 'three-lines.txt'
        a[ 1 ] and fail
      end
    end
  end
end
