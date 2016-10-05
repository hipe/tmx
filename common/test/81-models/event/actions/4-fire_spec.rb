require_relative '../../../test-support'

module Skylab::Common::TestSupport

  describe "[co] [..] fire" do

    TS_[ self ]
    use :expect_event

    it "with the ideal case - works" do

      _path = Home_.dir_path

      call_API(
        :fire,
        :file, _path,
        :const, 'Skylab::Common::TestSupport::FixtureFiles::ZigZag',
        :channel, 'hacking'
      )

      _em = expect_event :event_event

      black_and_white( _em.cached_event_value ).should match(
        %r(\Aevent: #<Skylab::Common::TestSupport::.*\bMock_Old_Event) )

      expect_succeeded
    end

    def subject_API
      Home_::CLI.application_kernel_
    end
  end
end
