require_relative '../../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node - actions - to-stream - against criteria" do

    extend TS_

    # (what is here is the salvagable remanents of reduction and CLI-
    # integration-related tests that used to be in what is now `crete_spec`)
    #

    it "etc", wip: true

    memoize_ :_s do

      <<-HERE.unindent.freeze
        [#004.2] #open this is #feature-creep but meh
        [#004] #open here's an open guy
                        with two lines
        [#003]        not open because no such tag
        [#002]       look for job #openings somewhere else
        [#leg-001]   this is an old ticket that is still #open
                       it has a prefix which will hopefully be ignored
      HERE
    end

    memoize_ :_s2 do

      <<-O.unindent
        ---
        identifier_body   : 004.2
        first_line_body   : #open this is #feature-creep but meh
        ---
      O
    end
  end
end
