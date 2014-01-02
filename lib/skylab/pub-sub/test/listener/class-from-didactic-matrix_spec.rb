require_relative 'test-support'

module Skylab::PubSub::TestSupport::Listener

  describe "[ps] listener from didactic matrix" do

    extend TS__

    before :all do

      Mofo_CFDM = PubSub::Listener::Class_from_diadic_matrix[
        %i( info error ), %i( string line ) ]


      class Emitter_CFDM
        def initialize a
          @a = a
        end
        def emit i, x
          @a.push i, x ; nil
        end
      end
    end

    it "when shape term is valid, it is simply ignored - o" do
      listener.call :info, :line do :hi end
      @a.should eql %i( info hi )
    end

    -> do
      msg = "no such shape 'event'. did you mean 'string' or 'line'?"

      it "#{ msg } - X" do
        -> do
          listener.call :info, :event do :hi end
        end.should raise_error ::KeyError, msg
      end
    end.call

    def build_emitter
      Emitter_CFDM.new( @a = [] )
    end

    def build_listener
      Mofo_CFDM.new emitter
    end
  end
end
