require_relative '../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - sequence" do

    TS_[ self ]

    context "the empty sequence" do

      memoize_subject_parse_function_ do
        subject_parse_module_.with :functions
      end

      it "builds" do
        subject_parse_function_
      end

      it "against nothing - succeeds" do
        expect( against_.value ).to eql EMPTY_A_
      end

      it "against something - parses nothing and succeeds" do
        st = input_stream_containing :foo
        expect( against_input_stream( st ).value ).to eql EMPTY_A_
        expect( st.current_index ).to be_zero
      end
    end

    context "a sequence of two rigid atomic items" do

      memoize_subject_parse_function_ do
        subject_parse_module_.with :functions,
          :keyword, 'foo',
          :keyword, 'bar'
      end

      it "against nothing - fails" do
        expect( against_ ).to be_nil
      end

      it "against one wrong token" do
        st = input_stream_containing 'fob'
        expect( against_input_stream st ).to be_nil
        expect( st.current_index ).to be_zero
      end

      it "against a right token then a wrong token - REWINDS" do
        st = input_stream_containing 'foo', 'bir'
        expect( against_input_stream st ).to be_nil
        expect( st.current_index ).to be_zero
      end

      it "against two right tokens and a wrong token" do
        st = input_stream_containing 'foo', 'bar', 'bozzo'
        expect( against_input_stream( st ).value ).to eql [ :foo, :bar ]
        expect( st.current_index ).to eql 2
      end
    end

    context "non-colliding range item, keyword (enter monadic range)" do

      memoize_subject_parse_function_ do
        subject_parse_module_.with( :functions,
          :zero_or_one, :keyword, 'foo',
          :keyword, 'bar' )
      end

      it "against nothing, nothing" do
        expect( against_ ).to be_nil
      end

      it "against strange, nothing" do
        st = input_stream_containing 'strange'
        expect( against_input_stream st ).to be_nil
        expect( st.current_index ).to be_zero
      end

      it "against minimal good" do
        st = input_stream_containing 'bar'
        expect( against_input_stream( st ).value ).to eql [ nil, :bar ]
        expect( st.current_index ).to eql 1
      end

      it "against minimal good plus one" do
        st = input_stream_containing 'bar', 'bar'
        expect( against_input_stream( st ).value ).to eql [ nil, :bar ]
        expect( st.current_index ).to eql 1
      end

      it "against maximal normal" do
        st = input_stream_containing 'foo', 'bar'
        expect( against_input_stream( st ).value ).to eql [ :foo, :bar ]
        expect( st.current_index ).to eql 2
      end

      it "looks like it might be good, then fails" do
        st = input_stream_containing 'foo', 'biz'
        expect( against_input_stream st ).to be_nil
        expect( st.current_index ).to be_zero
      end
    end

    context "non-colliding unbound range item, keyword (enter unbound range)" do

      memoize_subject_parse_function_ do
        subject_parse_module_.with :functions,
          :zero_or_more, :keyword, 'foo',
          :keyword, 'bar'
      end

      it "against nothing, nothing" do
        expect( against_ ).to be_nil
      end

      it "against strange, nothing" do
        st = input_stream_containing 'weird'
        expect( against_input_stream st ).to be_nil
        expect( st.current_index ).to be_zero
      end

      it "against minimal good" do
        st = input_stream_containing 'bar'
        expect( against_input_stream( st ).value ).to eql [ EMPTY_A_, :bar ]
        expect( st.current_index ).to eql 1
      end

      it "against good with one of the optionals" do
        st = input_stream_containing 'foo', 'bar'
        expect( against_input_stream( st ).value ).to eql [ [ :foo ], :bar ]
        expect( st.current_index ).to eql 2
      end

      it "against good with two of the optionals" do
        st = input_stream_containing 'foo', 'foo', 'bar'
        expect( against_input_stream( st ).value ).to eql [ [ :foo, :foo ], :bar ]
        expect( st.current_index ).to eql 3
      end

      it "looks good then fails" do
        st = input_stream_containing 'foo', 'biz'
        expect( against_input_stream st ).to be_nil
        expect( st.current_index ).to be_zero
      end
    end

    context "the minimal colliding sequence whose range term is monadic" do

      memoize_subject_parse_function_ do
        subject_parse_module_.with :functions,
          :zero_or_one, :keyword, 'zep',
          :keyword, 'zep'
      end

      it "against minimal good" do
        st = input_stream_containing 'zep'
        expect( against_input_stream( st ).value ).to eql [ nil, :zep ]
        expect( st.current_index ).to eql 1
      end

      it "against maximal good" do
        st = input_stream_containing 'zep', 'zep'
        expect( against_input_stream( st ).value ).to eql [ :zep, :zep ]
        expect( st.current_index ).to eql 2
      end
    end

    context "the minimal colliding sequence whose range term is unbound" do

      memoize_subject_parse_function_ do
        subject_parse_module_.with :functions,
          :zero_or_more, :keyword, 'zo',
          :keyword, 'zo'
      end

      it "against minimal good" do
        st = input_stream_containing 'zo'
        expect( against_input_stream( st ).value ).to eql [ EMPTY_A_, :zo ]
        expect( st.current_index ).to eql 1
      end

      it "with one optional" do
        st = input_stream_containing 'zo', 'zo'
        expect( against_input_stream( st ).value ).to eql [ [ :zo ], :zo ]
        expect( st.current_index ).to eql 2
      end

      it "with two optionals" do
        st = input_stream_containing 'zo', 'zo', 'zo'
        expect( against_input_stream( st ).value ).to eql [ [ :zo, :zo ], :zo ]
        expect( st.current_index ).to eql 3
      end
    end

    context "A+ A (enter any token, one or more)" do

      memoize_subject_parse_function_ do
        subject_parse_module_.with :functions,
          :one_or_more, :any_token,
          :keyword, 'zoink', :minimum_number_of_characters, 1

      end

      it "builds" do
        subject_parse_function_
      end

      it "one random keyword (satisfies first but not second term)" do
        st = input_stream_containing 'zippledeegoink'
        expect( against_input_stream st ).to be_nil
        expect( st.current_index ).to be_zero
      end

      it "the keyword but nothing else (second term won't be reached" do
        st = input_stream_containing 'zoink'
        expect( against_input_stream st ).to be_nil
        expect( st.current_index ).to be_zero
      end

      it "two keywords" do
        st = input_stream_containing 'zoink', 'zoi'
        expect( against_input_stream( st ).value ).to eql [ [ 'zoink' ], :zoink ]
        expect( st.current_index ).to eql 2
      end

      it "three keywords" do
        st = input_stream_containing 'z', 'z', 'z'
        expect( against_input_stream( st ).value ).to eql [ [ 'z', 'z' ], :zoink ]
        expect( st.current_index ).to eql 3
      end
    end

    context "A A+ (trailing unbound)" do

      memoize_subject_parse_function_ do
        subject_parse_module_.with :functions,
          :keyword, 'zank',
          :one_or_more, :any_token
      end

      it "just the keyword - fails" do
        st = input_stream_containing 'zank'
        expect( against_input_stream st ).to be_nil
        expect( st.current_index ).to be_zero
      end

      it "the keyword and one term - win" do
        st = input_stream_containing 'zank', 'zank'
        expect( against_input_stream( st ).value ).to eql [ :zank, [ 'zank' ] ]
        expect( st.current_index ).to eql 2
      end
    end

    context "A+ A A+" do

      memoize_subject_parse_function_ do
        subject_parse_module_.with :functions,
          :one_or_more, :any_token,
          :keyword, 'has', :minimum_number_of_characters, 1,
          :one_or_more, :any_token
      end

      it "fail on only the one keyword" do
        st = input_stream_containing 'has'
        expect( against_input_stream st ).to be_nil
        expect( st.current_index ).to be_zero
      end

      it "fails on two of three terms" do
        st = input_stream_containing 'x', 'has'
        expect( against_input_stream st ).to be_nil
        expect( st.current_index ).to be_zero
      end

      it "fail on two keywords" do
        st = input_stream_containing 'has', 'has'
        expect( against_input_stream st ).to be_nil
        expect( st.current_index ).to be_zero
      end

      it "succeeds with three normal" do
        st = input_stream_containing 'X', 'has', 'Y'
        expect( against_input_stream( st ).value ).to eql [ ['X'], :has, ['Y'] ]
        expect( st.current_index ).to eql 3
      end

      it "succeeds with three keywords" do
        st = input_stream_containing 'ha', 'ha', 'ha'
        expect( against_input_stream( st ).value ).to eql [ ['ha'], :has, ['ha'] ]
        expect( st.current_index ).to eql 3
      end

      it "one further (four) shows greediness" do
        st = input_stream_containing 'h', 'h', 'h', 'h'
        expect( against_input_stream( st ).value ).to eql [ %w( h h ), :has, [ "h" ] ]
        expect( st.current_index ).to eql 4
      end
    end

    context "the catalyst case (enter a compound grammar (curries inside curries))" do

      memoize_subject_parse_function_ do
        subject_parse_module_.with :functions,
          :one_or_more, :any_token,
          :sequence, :functions,
            :keyword, "would",
            :keyword, "like",
            :end_functions,
          :one_or_more, :any_token
      end

      it "builds" do
        subject_parse_function_
      end

      it "omg minimal passing" do
        st = input_stream_containing 'i', 'would', 'like', 'soup'
        expect( against_input_stream( st ).value ).to eql [ %w( i ), [ :would, :like ], %w( soup ) ]
        expect( st.current_index ).to eql 4
      end

      it "OMG THE DIFFICULT CASE" do

        st = input_stream_containing 'would', 'like', 'would', 'like', 'would', 'like'

        expect( against_input_stream( st ).value ).to eql(

          [ %w( would like ), [ :would, :like ], %w( would like ) ] )

        expect( st.current_index ).to eql 6
      end

      it "render the syntax string with the default design" do
        expect( subject_parse_function_.express_all_segments_into_under( "" ) ).to eql(
          '(ANY_TOKEN)+ would like (ANY_TOKEN)+' )
      end
    end

    def self.subject_parse_module_
      Home_.function :sequence
    end
  end
end
