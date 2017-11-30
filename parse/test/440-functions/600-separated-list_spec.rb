require_relative '../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - separated list" do

    TS_[ self ]

    same_item_proc = -> in_st do
      if in_st.unparsed_exists
        in_st.gets_one.value
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
        expect( _x.value ).to eql [ 'one', 'two' ]
        expect( st.unparsed_exists ).to eql false
      end

      it "against two items plus" do

        st = input_stream_containing 'one', 'or', 'two', 'or'
        _x = against_input_stream st
        expect( _x.value ).to eql [ 'one', 'two' ]
        expect( st.unparsed_exists ).to eql true
        expect( st.current_index ).to eql 3
      end

      it "three" do

        st = input_stream_via_array %w( 0 or 1 or 2 )
        expect( against_input_stream( st ).value ).to eql %w( 0 1 2 )
        expect( st.unparsed_exists ).to eql false
      end

      it "three plus 'or'" do

        _three input_stream_via_array %w( 0 or 1 or 2 or )
      end

      it "three plus 'X'" do

        _three input_stream_via_array %w( 0 or 1 or 2 X )
      end

      def _three st

        expect( against_input_stream( st ).value ).to eql %w( 0 1 2 )
        expect( st.unparsed_exists ).to eql true
        expect( st.current_index ).to eql 5
      end

      memoize_subject_parse_function_ do
        _subject_parse_module.with(
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
        expect( against_input_stream( st ).value ).to eql %w( A B )
        expect( st.unparsed_exists ).to eql false
      end

      it "two the false prophet - using a comma with no final separator - NO" do

        st = input_stream_via_array %w( A , B )
        expect( against_input_stream( st ) ).to be_nil
        expect( st.current_index ).to be_zero
      end

      it "etc" do

        st = input_stream_via_array %w( A , B , C or D x )
        expect( against_input_stream( st ).value ).to eql %w( A B C D )
        expect( st.unparsed_exists ).to eql true
        expect( st.current_index ).to eql 7
      end

      memoize_subject_parse_function_ do
        _subject_parse_module.with(
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

      expect( x ).to be_nil
      expect( st.current_index ).to be_zero
    end

    def self._subject_parse_module
      Home_.function :separated_list
    end
  end
end
