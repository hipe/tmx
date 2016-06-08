require_relative 'test-support'

module Skylab::Common::TestSupport::Selective_Listener

  describe "[co] selective listener - make via didactic matrix" do

    extend TS__

    before :all do

      Mofo_CFDM = Subject_[].make_via_didactic_matrix [ :info, :error ], [ :string, :line ]

      class Digraph_CFDM
        def initialize a
          @a = a
        end
        def call_digraph_listeners i, x
          @a.push i, x ; nil
        end
      end
    end

    it "when shape term is valid, it is simply ignored - o" do
      listener.maybe_receive_event :info, :line, :hi
      @a.should eql %i( info hi )
    end

    -> do
      msg = "no such shape 'event'. did you mean 'string' or 'line'?"

      it "#{ msg } - X" do
        -> do
          listener.maybe_receive_event :info, :event, :hi
        end.should raise_error ::KeyError, msg
      end
    end.call

    def build_digraph_emitter
      Digraph_CFDM.new( @a = [] )
    end

    def build_listener
      Mofo_CFDM.new emitter
    end
  end
end
