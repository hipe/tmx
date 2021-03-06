require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] core operations - files" do

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

          expect( _ ).to include_alternation_for_(
            %w( paths path filename_patterns filename_pattern ) )
        end

        expect( only_emission ).to _be_this
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

          expect( y.last ).to be_include ' end of phrase - unexpected argument: \'wa'
        end

        expect( only_emission ).to _be_this
      end
    end

    context "required list args are empty arrays" do

      shared_subject :exception_message_lines do
        argument_error_lines do
          call(
            :paths, EMPTY_A_,
            :filename_patterns, EMPTY_A_,
            :search, :files_by_find,
          )
        end
      end

      it "one line" do
        1 == exception_message_lines.length or fail
      end

      it "first line" do
        _ex = "'search' 'files-by-find' is missing required parameter 'paths'." or fail
        _ = first_line
        _ == _ex or fail
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

        expect( last_emission ).to be_emission( :info, :event, :find_command_args )
      end

      it "result is a stream of the matched files" do

        st = root_ACS_result
        _ = st.gets
        __ = st.gets
        expect( st.gets ).to be_nil

        expect( basename_ _ ).to eql 'one-line.txt'
        expect( basename_ __ ).to eql _THREE_LINES_FILE
      end
    end

    context "(deep missing required)" do

      shared_subject :exception_message_lines do

        argument_error_lines do

          call(
            :ruby_regexp, 'xx',
            :paths, EMPTY_A_,
            :search,
            :files_by_grep,
          )
        end
      end

      it "first line - synopsis" do
        _exp = "to 'search' 'files-by-grep', must 'files-by-find'\n"
        _exp == first_line or fail
      end

      it "second line - deeper" do
        _exp = "'files-by-find' is missing required parameter 'paths'."
        _exp == second_line or fail
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

        expect( last_emission ).to be_emission_ending_with :grep_command_head
      end

      it "result is a stream of paths" do

        a = root_ACS_customized_result
        expect( basename_( a.fetch 0 ) ).to eql 'three-lines.txt'
        a[ 1 ] and fail
      end
    end
  end
end
