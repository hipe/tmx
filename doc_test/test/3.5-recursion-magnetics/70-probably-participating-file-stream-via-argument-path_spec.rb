require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] recursion mags - probably [..]" do

    TS_[ self ]
    use :recursion_magnetics

    it "loads" do
      _subject_mag
    end

    it "runny money" do

      _dir = TestSupport_::Fixtures.tree :three

      _st = __against _dir

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

    def __against ap
      _subject_mag[ ap, name_conventions_ ]
    end

    def _subject_mag
      Home_::RecursionMagnetics_::ProbablyParticipatingFileStream_via_ArgumentPath
    end
  end
end
