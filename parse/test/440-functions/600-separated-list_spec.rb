require_relative '../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - separated list" do

    TS_[ self ]

    same_item_proc = -> in_st do
      if in_st.unparsed_exists
        in_st.gets_one.value_x
      end
    end

    context "single sep" do

      it "builds" do
        subject_parse_function_
      end

      it "against empty input - does not parse" do
        _nothing_against_empty
      end

      it "against one item - does not parse" do
        _nothing_against_one
      end

      it "against two items" do

        st = input_stream_containing 'one', 'or', 'two'
        _x = against_input_stream st
        _x.value_x.should eql [ 'one', 'two' ]
        st.unparsed_exists.should eql false
      end

      it "against two items plus" do

        st = input_stream_containing 'one', 'or', 'two', 'or'
        _x = against_input_stream st
        _x.value_x.should eql [ 'one', 'two' ]
        st.unparsed_exists.should eql true
        st.current_index.should eql 3
      end

      it "three" do

        st = input_stream_via_array %w( 0 or 1 or 2 )
        against_input_stream( st ).value_x.should eql %w( 0 1 2 )
        st.unparsed_exists.should eql false
      end

      it "three plus 'or'" do

        _three input_stream_via_array %w( 0 or 1 or 2 or )
      end

      it "three plus 'X'" do

        _three input_stream_via_array %w( 0 or 1 or 2 X )
      end

      def _three st

        against_input_stream( st ).value_x.should eql %w( 0 1 2 )
        st.unparsed_exists.should eql true
        st.current_index.should eql 5
      end

      memoize_subject_parse_function_ do
        _subject_parse_module.new_with(
          :item, :proc, same_item_proc,
          :separator, :keyword, 'or' )
      end
    end

    context "multi sep" do

      it "empty" do
        _nothing_against_empty
      end

      it "one" do
        _nothing_against_one
      end

      it "two" do

        st = input_stream_via_array %w( A or B )
        against_input_stream( st ).value_x.should eql %w( A B )
        st.unparsed_exists.should eql false
      end

      it "two the false prophet - using a comma with no final separator - NO" do

        st = input_stream_via_array %w( A , B )
        against_input_stream( st ).should be_nil
        st.current_index.should be_zero
      end

      it "etc" do

        st = input_stream_via_array %w( A , B , C or D x )
        against_input_stream( st ).value_x.should eql %w( A B C D )
        st.unparsed_exists.should eql true
        st.current_index.should eql 7
      end

      memoize_subject_parse_function_ do
        _subject_parse_module.new_with(
          :item, :proc, same_item_proc,
          :ultimate_separator, :keyword, 'or',
          :non_ultimate_separator, :keyword, ',' )
      end
    end

    def _nothing_against_empty

      st = input_stream_containing
      _x = against_input_stream st
      _nothing _x, st
    end

    def _nothing_against_one

      st = input_stream_containing 'one'
      _x = against_input_stream st
      _nothing _x, st
    end

    def _nothing x, st

      x.should be_nil
      st.current_index.should be_zero
    end

    def self._subject_parse_module
      Home_.function :separated_list
    end
  end
end
