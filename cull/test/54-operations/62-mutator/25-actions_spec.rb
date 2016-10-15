require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - mutator actions" do

    TS_[ self ]
    use :expect_event

    it "lists" do

      call_API :mutator, :list
      expect_no_events

      st = @result
      x = st.gets
      x.as_slug.should match %r(\Aremove-empty)

    end
  end
end
