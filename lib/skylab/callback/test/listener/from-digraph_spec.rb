require_relative 'test-support'

module Skylab::Callback::TestSupport::Listener

  describe "[cb] listener from emitter" do

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
      listener.call_any_listener :info do :shazam end
      @a.should eql %i( info shazam )
    end

    it "must have same arity - (a deep bug lurks behind this) - X" do
      -> do
        listener.call_any_listener( :one, :two ) do :_no_see_ end
      end.should raise_error ::ArgumentError,
        /\bwrong number of arguments \(3 for 2\)/
    end

    def build_listener
      Callback::Listener::From_digraph_emitter[ emitter ]
    end

    def build_digraph_emitter
      Digraph_FD.new( @a = [] )
    end
  end
end
