require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] callback tree - listeners" do

    context "minimal normative example" do

      it "listener gets notified" do
        seen = nil
        callbacks.add_listener :za_zang, -> x do seen = x end
        r = callbacks.call_listeners :za_zang do :ga_zoink end
        seen.should eql :ga_zoink
        r.should be_nil
      end

      it "try to add a listener for a nonexist channel" do

        _rx = /\Athere is no 'no_existo' channel at the 'root' node/

        begin
          callbacks.add_listener :no_existo, :_fake_p_
        rescue ::KeyError => e
        end

        e.message =~ _rx || fail
      end

      it "try to call a call that goes off the end" do

        _rx = /\Aoff the end: 'feeple_deeple'/
        begin
          callbacks.call_listeners :za_zang, :feeple_deeple do :xyzizzy end
        rescue ::KeyError => e
        end

        e.message =~ _rx || fail
      end

      let :callbacks do
        Home_::CallbackTree.new za_zang: :listeners
      end
    end

    context "a typical listeners tree" do

      it "calling an event outside of the tree is a no-no" do

        _rx = /\Ano 'i_am' at this node\. the only known node is 'error'\z/

        begin
          callbacks.call_listeners :i_am, :not_there do self._never_see_ end
        rescue ::KeyError => e
        end

        e.message =~ _rx || fail
      end

      it "no listeners: not only does no body hear it, but it doesn't fall" do
        r = callbacks.call_listeners :error, :purple, :durple_error do
          self._never_see_
        end
        r.should be_nil
      end

      it "when one listener subscribes to the money, the money gets it" do
        seen = nil
        p = -> x do
          seen = x ; :_no_see_
        end
        callbacks.add_listener :error, :purple, :durple_error, p
        r = callbacks.call_listeners :error, :purple, :durple_error do :ohai end
        r.should be_nil
        seen.should eql :ohai
      end

      it "when a listener subscribes to two levels above, gets it too" do
        seen_1 = seen_2 = nil
        callbacks.add_listener :error, -> x do
          seen_1 = x
        end
        callbacks.add_listener :error, :purple, :durple_error, -> x do
          seen_2 = x
        end
        callbacks.call_listeners :error, :purple, :durple_error do :yep end
        seen_1.should eql :yep
        seen_2.should eql :yep
      end

      let :callbacks do
        Home_::CallbackTree.new error: { purple: { durple_error: :listeners } }
      end
    end
  end
end
