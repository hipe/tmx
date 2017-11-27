require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] selective listener - make via didactic matrix" do

    TS_[ self ]
    use :selective_listener

    before :all do

      X_sl_mvm_Mofo = Home_::Selective_Listener.make_via_didactic_matrix [ :info, :error ], [ :string, :line ]

      class X_sl_mvm_Digraph
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
      expect( @a ).to eql %i( info hi )
    end

    -> do

      msg = "no such shape 'event'. did you mean 'string' or 'line'?"

      it "#{ msg } - X" do

        begin
          listener.maybe_receive_event :info, :event, :hi
        rescue ::KeyError => e
        end

        e.message == msg || fail
      end
    end.call

    def build_digraph_emitter
      X_sl_mvm_Digraph.new( @a = [] )
    end

    def build_listener
      X_sl_mvm_Mofo.new emitter
    end
  end
end
