require_relative '../test-support'

module Skylab::Plugin::TestSupport

  describe "[ba] queue [action queue] - args" do

    TS_[ self ]
    use :memoizer_methods
    use :models_lazy_index

    it "if you enqueue after you produce the scanner, it won't make it in" do

      subj = subject_module_.define do |_|
        NOTHING_
      end

      subj.enqueue 33
      subj.enqueue 66
      scn1 = subj.to_scanner_of_offsets_of_plugins_with_pending_execution
      subj.enqueue 99
      scn2 = subj.to_scanner_of_offsets_of_plugins_with_pending_execution

      33 == scn1.gets_one || fail
      33 == scn2.gets_one || fail

      66 == scn1.gets_one || fail
      66 == scn2.gets_one || fail

      scn1.no_unparsed_exists || fail
      scn2.no_unparsed_exists && fail

      99 == scn2.gets_one || fail
      scn2.no_unparsed_exists || fail

    end
  end
end
# #tombstone-A: rewrite of [br]-era queue
