require_relative '../test-support'

module Skylab::GitViz::TestSupport::Lib_Hndlrs__

  ::Skylab::GitViz::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[gv] lib- handlers" do

    context "a typical handlers tree" do

      it "on the money is on the money" do
        hndlrs.set :error, :frobulation, :sub_cutaneous, method( :handle_it )
        same_story
      end

      it "one level up will catch it" do
        hndlrs.set :error, :frobulation, method( :handle_it )
        same_story
      end

      it "two levels up will catch it" do
        hndlrs.set :error, method( :handle_it )
        same_story
      end
    end

    context "some peripheries" do

      it "a misfire of no such channel - X" do
        -> do
          hndlrs.call :error, :frobulation, :epi_tantric, :x
        end.should raise_error ::KeyError, /\Athere is no 'epi_tantric' #{
         }channel at the 'error frobulation' node. known channels are #{
          }'trans_dermal' and 'sub_cutaneous' \(for the wazlo handlers\)\z/
      end

      it "a block passed vs a handler (anywhere) above - handler wins" do
        hndlrs.set :error, method( :handle_it )
        @r = hndlrs.call :error, :frobulation, :trans_dermal, :y do :_nope_ end
        same_result
      end

      it "a block passed when no handler above - block wins" do
        @r = hndlrs.call :error, :frobulation, :trans_dermal, :y, &
          method( :handle_it )
        same_result
      end

      it "try to set a nonnexistent channel - X" do
        -> do
          hndlrs.set :error, :zoey_deschanel, :_no_see_
        end.should raise_error KeyError, /\Athere is no 'zoey_deschanel' #{
          }channel at the 'error' node\. the only known channel is #{
           }'frobulation' \(for the wazlo handlers\)\z/
      end
    end

    let :hndlrs do
      GitViz::Lib_::Handlers.
        new( { error: { frobulation:
          { trans_dermal: nil, sub_cutaneous: nil } } }, :wazlo )
    end

    def handle_it x
      @x = x
      :_hello_from_handle_it_
    end

    def same_story
      same_setup
      same_result
    end

    def same_setup
      @r = hndlrs.call :error, :frobulation, :sub_cutaneous, :y
    end

    def same_result
      @x.should eql :y
      @r.should eql :_hello_from_handle_it_
    end
  end
end
