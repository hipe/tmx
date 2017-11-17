require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - mutator actions", wip: true do

    TS_[ self ]
    use :want_event

# (1/N)
    it "lists" do

      call_API :mutator, :list
      want_no_events

      st = @result
      x = st.gets
      x.as_slug.should match %r(\Aremove-empty)

    end
  end
end
