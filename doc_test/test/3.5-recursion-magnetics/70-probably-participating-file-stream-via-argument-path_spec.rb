require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] recursion mags - probably [..]" do

    TS_[ self ]

    it "loads" do
      _subject_mag
    end

    it "runny money" do

      _omg = TestSupport_::Fixtures.tree :three

      _st = _subject_mag[ _omg ]

      a = []
      a.push _st.gets
      a.push _st.gets
      a.push _st.gets   # nil one time
      a.push _st.gets   # nil another time

      a.pop.nil? || fail
      a.pop.nil? || fail

      # these lines are coming directly from `grep` so we're not going
      # to validate their content (for now), just that they're set, and
      # that there's these two of them set

      a[0] || fail
      a[1] || fail
    end

    def _subject_mag
      Home_::RecursionMagnetics_::ProbablyParticipatingFileStream_via_ArgumentPath
    end
  end
end
