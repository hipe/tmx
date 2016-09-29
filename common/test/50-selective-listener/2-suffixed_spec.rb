require_relative 'test-support'

module Skylab::Common::TestSupport::Selective_Listener

  describe "[co] selective listener - suffixed" do

    extend TS__

    before :all do
      class Client_SFFXD
        def initialize a
          @a = a
        end
      private
        def wiff_waff_from_agent x
          @a.push :wff, :wff, x ; nil
        end
        def wazzozle_from_agent x
          @a.push :wzzzl, x ; nil
        end
      end
    end

    it "makes a listener that sends method calls downwards w suffix - o" do
      listener.maybe_receive_event :wazzozle, :x
      @listener.maybe_receive_event :wiff, :waff, :z
      @a.should eql %i( wzzzl x wff wff z )
    end

    it "when an unsupported channel name is emitted - X" do
      -> do
        listener.maybe_receive_event :montoya, :_no_see_
      end.should raise_error ::NoMethodError,
        /\bundefined method `montoya_from_agent'/
    end

    def build_listener
      Subject_[].suffixed client, :from_agent
    end

    def build_client
      @a = []
      Client_SFFXD.new @a
    end
  end
end
