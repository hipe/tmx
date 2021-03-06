require_relative '../../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - upstream map (markdown (vertical)", wip: true do

    TS_[ self ]
    use :want_event

# (1/N)
    it "files must be absolute here" do
      call_API :upstream, :map, :upstream, 'non-absolute-path'
      want_not_OK_event :path_must_be_absolute
      want_fail
    end

# (2/N)
    it "empty file" do

      markdown_map_against_file :zero_bytes

      _em = want_not_OK_event :early_end_of_stream

      expect( black_and_white( _em.cached_event_value ) ).to match(
        /\Aearly end of stream - there were no markdown tables anywhere/ )

      want_fail
    end

# (3/N)
    it "file with one empty line" do
      markdown_map_against_file :one_newline_only
      want_not_OK_event :early_end_of_stream
      want_fail
    end

    def markdown_map_against_file sym
      call_API :upstream, :map, :upstream,
        TestSupport_::Fixtures.file( sym ),
          :upstream_adapter, :markdown
    end

# (4/N)
    it "and existent" do

      map_against_file :GFM_misc

      want_no_events

      st = @result

      e = st.gets
      e_ = st.gets

      expect( st.gets ).to eql Home_::NIL_

      expect( e.to_even_iambic ).to eql(
        [ :"First Header", "Content Cell",
            :"Second Header", "Content Cell" ] )

      expect( e_.to_even_iambic ).to eql(
        [ :"First Header", "Content Cell",
            :"Second Header", "Content Cell" ] )

    end

# (5/N)
    it "table number is too low" do

      map_against_file :GFM_misc, :table_number, '0'

      _em = want_not_OK_event_ :number_too_small

      expect( black_and_white( _em.cached_event_value ) ).to match(
        /\A'table-number' must be greater than or equal to 1, had 0/ )

      want_fail
    end

# (6/N)
    it "table number too high" do

      map_against_file :GFM_misc, :table_number, '6'

      _em = want_not_OK_event :early_end_of_stream

      expect( black_and_white( _em.cached_event_value ) ).to match(
        / - needed 6 but had only 5 markdown tables in the entirety of the\b/ )

      want_fail
    end

# (7/N)
    it "table number works" do

      map_against_file :GFM_misc, :table_number, '5'

      want_no_events

      st = @result
      e1 = st.gets
      e2 = st.gets
      e3 = st.gets

      i_a = [ :"Left-Aligned", :"Center Aligned", :"Right Aligned" ]

      expect( e1.at_fields( i_a ) ).to eql [ 'col 3 is', 'some wordy text', '$1600' ]
      expect( e2.at_fields( i_a ) ).to eql [ 'col 2 is', 'centered', '$12' ]
      expect( e3.at_fields( i_a ) ).to eql [ 'zebra stripes', 'are neat', '$1' ]

    end

    def map_against_file sym, * x_a

      call_API :upstream, :map,
        :upstream, file( sym ),
        :upstream_adapter, :markdown,
        * x_a

      nil
    end

  end
end
