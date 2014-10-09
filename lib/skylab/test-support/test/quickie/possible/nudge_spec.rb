require_relative 'test-support'

module Skylab::TestSupport::TestSupport::Quickie::Possible_

  describe "[ts] quickie possible nudge" do

    include Possible_TS_::InstanceMethods

    context "with a graph with two nodes" do

      before :all do
        module Diadic
          Possible_::Graph[ self ]
          A = eventpoint
          B = eventpoint { from A }
        end
      end

      def possible_graph
        Diadic.possible_graph
      end

      it "reconcile with nothing" do
        r = recon :A, :B, []
        r.should eql( false )
        expect_line "there are no active agents"
        expect_line "so the system cannot reach the B state"
        # might be details
      end

      it "reconcile with one dud signature #redundant-sounding" do
        r = recon :A, :B, [ new_sig ]
        r.should eql( false )
        expect_line "the only active agent does not bring the system #{
          }to the B state"
        expect_only_line "the only active agent failed to get #{
          }passed the A state"
      end

      it "reconcile with two dud signatures #redundant-sounding" do
        r = recon :A, :B, [ new_sig, new_sig ]
        r.should eql( false )
        expect_line "none of the two active agents bring the system #{
          }to the B state"
        expect_line "none of the two active agents got passed the A state"
      end

      it "reconcile with bad name signature - key error at recon time" do
        (( sig = new_sig )).nudge :feeple, :deeple
        -> do
          recon :A, :B, [ sig ]
        end.should raise_error( ::KeyError, /key not found: :feeple/ )
      end

      it "reconcile with invalid direction - rt at recon time" do
        (( sig = new_sig )).nudge :B, :A
        -> do
          recon :A, :B, [ sig ]
        end.should raise_error( ::RuntimeError, "signature error - meh #{
          }expresses an invalid transition from B to A (B does not #{
          }transition to any other nodes)" )
      end

      it "reconcile one nudge - WORKS" do
        (( sig = new_sig )).nudge :A, :B
        x = recon :A, :B, [ sig ]
        x.should eql( true )
      end

      it "reconcile with ambiguous nudges - soft failure" do
        (( sig1 = new_sig :beavis   )).nudge :A, :B
        (( sig2 = new_sig :butthead )).nudge :A, :B
        ok, grid = recon_plus :A, :B, [ sig1, sig2 ]
        ok.should eql( false )
        grid.fetch_frame( 0 ).get_exponent.should eql( :agents_ambiguity )
      end
    end
  end
end
