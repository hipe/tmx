require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] selective listener - via digraph [emitter]" do

    TS_[ self ]
    use :selective_listener

    before :all do
      class X_sl_vd_Digraph
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
      expect( @a ).to eql %i( info shazam )
    end

    it "must have same arity - (a deep bug lurks behind this) - X" do

      _rx = /\bwrong number of arguments \(given 3, expected 2\)/

      begin
        listener.maybe_receive_event :one, :two, :_no_see_
      rescue ::ArgumentError => e
      end

      e.message =~ _rx || fail
    end

    def build_listener
      subject_module_.via_digraph_emitter emitter
    end

    def build_digraph_emitter
      X_sl_vd_Digraph.new( @a = [] )
    end
  end
end
