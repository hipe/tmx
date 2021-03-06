require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] callback tree - handlers" do

    TS_[ self ]
    use :the_method_called_let

    context "a typical handlers tree" do

      it "on the money is on the money" do
        hndlrs.set_handler :error, :frobulation, :sub_cutaneous,
          method( :handle_it )
        same_story
      end

      it "one level up will catch it" do
        hndlrs.set_handler :error, :frobulation, method( :handle_it )
        same_story
      end

      it "two levels up will catch it" do
        hndlrs.set_handler :error, method( :handle_it )
        same_story
      end
    end

    context "some peripheries" do

      it "a misfire of no such channel - X" do
        expect( -> do
          hndlrs.call_handler :error, :frobulation, :epi_tantric, :x
        end ).to raise_error ::KeyError, /\Athere is no 'epi_tantric' #{
         }channel at the 'error frobulation' node. known channels are #{
          }'trans_dermal' and 'sub_cutaneous' \(for the wazlo callbacks\)\z/
      end

      it "a block passed vs a handler (anywhere) above - handler wins" do
        hndlrs.set_handler :error, method( :handle_it )
        @r = hndlrs.call_handler :error, :frobulation, :trans_dermal, :y do
          :_nope_
        end
        same_result
      end

      it "a block passed when no handler above - block wins" do
        @r = hndlrs.call_handler :error, :frobulation, :trans_dermal, :y, &
          method( :handle_it )
        same_result
      end

      it "try to set_handler a nonnexistent channel - X" do
        expect( -> do
          hndlrs.set_handler :error, :zoey_deschanel, :_no_see_
        end ).to raise_error KeyError, /\Athere is no 'zoey_deschanel' #{
          }channel at the 'error' node\. the only known channel is #{
           }'frobulation' \(for the wazlo callbacks\)\z/
      end
    end

    let :hndlrs do
      Home_::CallbackTree.new( { error: { frobulation:
        { trans_dermal: :handler, sub_cutaneous: :handler } } }, :wazlo )
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
      @r = hndlrs.call_handler :error, :frobulation, :sub_cutaneous, :y
    end

    def same_result
      expect( @x ).to eql :y
      expect( @r ).to eql :_hello_from_handle_it_
    end
  end
end
