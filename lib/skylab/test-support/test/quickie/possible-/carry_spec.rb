require_relative 'test-support'

module Skylab::TestSupport::TestSupport::Quickie::Possible_

  describe "#{ Quickie::Possible_ } carry" do

    include Possible_TS_::InstanceMethods

    context "with a Y-shaped graph with two nodes" do

      before :all do
        module Y_shape
          Possible_::Graph_[ self ]
          A = eventpoint
          B = eventpoint { from A }
          C = eventpoint { from B }
          D = eventpoint { from C ; from B }
        end
      end

      def possible_graph
        Y_shape.possible_graph
      end

      let :sig1 do
        sig = new_sig :sig1
        sig.nudge :A, :B
        sig.nudge :B, :C
        sig.nudge :C, :D
        sig
      end

      let :sig2 do
        sig = new_sig :sig2
        sig.carry :B, :D
        sig
      end

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
