require_relative '../../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - upstream map (markdown (horizontal)", wip: true do

    TS_[ self ]
    use :want_event

# (1/N)
    it "money" do  # #lends-coverage to #[#fi-008.6]

      map_against_file :horizontal_01_first_my_md
      want_no_events
      st = @result

      e1 = st.gets
      e2 = st.gets
      expect( st.gets ).to be_nil

      expect( e1.to_even_iambic ).to eql(
        [ :name, "haskell", :cost, "difficult for me to learn" ] )

      expect( e2.to_even_iambic ).to eql(
        [ :name, "swift", :cost, "fun now" ] )
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
