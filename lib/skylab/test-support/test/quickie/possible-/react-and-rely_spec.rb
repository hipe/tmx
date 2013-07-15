require_relative 'test-support'

module Skylab::TestSupport::TestSupport::Quickie::Possible_

  describe "#{ Quickie::Possible_ } react and rely" do

    include Possible_TS_::InstanceMethods

    context "with a triangle" do

      before :all do
        module Triangle
          Possible_::Graph_[ self ]
          A = eventpoint
          B = eventpoint { from A }
          C = eventpoint { from B ; from A }
        end
      end

      def possible_graph
        Triangle.possible_graph
      end

      let :sig1 do
        sig = new_sig :sig1
        sig.rely :B
        sig
      end

      it "a reconcliation that does not reach the goal short circuits" do
        ok, grid = recon_plus :A, :C, [ sig1 ]
        ok.should eql( false )
        grid.map( & :get_exponent ).should be_include( :agents_bring )
      end

      let :sig2 do
        sig = new_sig :sig2
        sig.nudge :A, :C
        sig.carry :B, :C
        sig
      end

      it "sig 2 short-circuits - sig 1 is not happy b.c it needs B" do
        ok, grid = recon_plus :A, :C, [ sig1, sig2 ]
        ok.should eql( false )
        grid.fetch_frame( 0 ).get_exponent.
          should eql( :signature_unmet_reliance )
      end

      let :sig3 do
        sig = new_sig :sig3
        sig.react :B
        sig
      end

      it "sig 2 short-circuits - sig 3 is ok because it doesn't *NEED* B BUT WHIMPERS!!" do
        ok, _x = recon_plus :A, :C, [ sig2, sig3 ]
        ok.should eql( true )
        expect_only_line( "sig3 will have no effect because the system #{
          }does not reach the B state" )
      end

      let :sig4 do
        sig = new_sig :sig4
        sig.carry :A, :B
        sig.nudge :B, :C
        sig
      end

      it "sig 4 which goes the long way around, satisfies 1 and 3" do
        ok, path = recon_plus :A, :C, [ sig1, sig2, sig3, sig4 ]
        ok.should eql( true )
        path.map( & :client ).should eql( [ :sig4, :sig2 ] )
      end
    end
  end
end
