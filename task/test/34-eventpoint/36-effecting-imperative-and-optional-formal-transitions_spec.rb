require_relative '../test-support'

module Skylab::Task::TestSupport

  describe "[ta] eventpoint - effecting passive and active formal transitions" do

    TS_[ self ]
    use :memoizer_methods
    use :eventpoint

    it "graph builds" do
      _graph || fail
    end

    it "agent with only passive transitions builds" do
      _agent_one || fail
    end

    it "agent with only one active transition builds" do
      _agent_two || fail
    end

    shared_subject :_graph do

      define_graph_ do |o|

        o.add_state :A,
          :can_transition_to, [ :B ]

        o.add_state :B,
          :can_transition_to, [ :C, :D ]

        o.add_state :C,
          :can_transition_to, [ :D ]

        o.add_state :D

        o.beginning_state :A
      end
    end

    shared_subject :_agent_one do
      define_agent_ do |o|
        o.can_transition_from_to :A, :B
        o.can_transition_from_to :B, :C
        o.can_transition_from_to :C, :D
      end
    end

    shared_subject :_agent_two do
      define_agent_ do |o|
        o.must_transition_from_to :B, :D
      end
    end

      if false

      it "normally signature 1 can carry it"  do
        ok, path = recon_plus :A, :D, [ sig1 ]
        ok.should eql( true )
        path.length.should eql( 3 )
        path.map( & :client ).should eql( [ :sig1, :sig1, :sig1 ] )
      end

      it "signature 2 alone won't reach it" do
        ok, grid = recon_plus :A, :D, [ sig2 ]
        ok.should eql( false )
        a = grid.map( & :get_exponent )
        a.should be_include( :agents_bring )
      end

      it "but SOMETHING MAGICAL happens when they are together" do
        ok, path = recon_plus :A, :D, [ sig1, sig2 ]
        ok.should eql( true )
        path.map( & :client ).should eql( [:sig1, :sig2] )
      end

      end
  end
end
# #history: first half of major rewrite
