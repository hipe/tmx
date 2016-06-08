require_relative '../../../test-support'

module Skylab::Callback::TestSupport

  describe "[ca] [..] fire" do

    extend TS_
    TS_::Expect_Event[ self ]

    it "with the ideal case - works" do

      _path = Home_.dir_pathname.to_path

      call_API(
        :fire,
        :file, _path,
        :const, 'Skylab::Callback::TestSupport::Fixtures::ZigZag',
        :channel, 'hacking'
      )

      _em = expect_event :event_event

      black_and_white( _em.cached_event_value ).should match(
        %r(\Aevent: #<Skylab::Callback::TestSupport::.*\bMock_Old_Event) )

      expect_succeeded
    end

    def subject_API
      Home_::CLI._application_kernel
    end
  end
end
