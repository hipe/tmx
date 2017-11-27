require_relative '../../../test-support'

module Skylab::Common::TestSupport

  describe "[co] [..] fire" do

    TS_[ self ]
    use :want_emission

    it "with the ideal case - works" do

      _path = Home_.dir_path

      call_API(
        :fire,
        :file, _path,
        :const, 'Skylab::Common::TestSupport::FixtureFiles::ZigZag',
        :channel, 'hacking'
      )

      _em = want_event :event_event

      expect( black_and_white( _em.cached_event_value ) ).to match(
        %r(\Aevent: #<Skylab::Common::TestSupport::.*\bMock_Old_Event) )

      want_succeed
    end

    def subject_API
      Home_::CLI.application_kernel_
    end
  end
end
