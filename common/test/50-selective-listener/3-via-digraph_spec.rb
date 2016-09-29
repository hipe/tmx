require_relative 'test-support'

module Skylab::Common::TestSupport::Selective_Listener

  describe "[co] selective listener - via digraph [emitter]" do

    extend TS__

    before :all do
      class Digraph_FD
        def initialize a
          @a = a
        end
        def call_digraph_listeners i, x
          @a.push i, x ; nil
        end
      end
    end

    it "simply dispatches simple channel emissions to an emitter - o" do
      listener.maybe_receive_event :info, :shazam
      @a.should eql %i( info shazam )
    end

    it "must have same arity - (a deep bug lurks behind this) - X" do
      -> do
        listener.maybe_receive_event :one, :two, :_no_see_
      end.should raise_error ::ArgumentError,
        /\bwrong number of arguments \(3 for 2\)/
    end

    def build_listener
      Subject_[].via_digraph_emitter emitter
    end

    def build_digraph_emitter
      Digraph_FD.new( @a = [] )
    end
  end
end
