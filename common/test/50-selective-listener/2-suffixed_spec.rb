require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] selective listener - suffixed" do

    TS_[ self ]
    use :selective_listener

    before :all do
      class X_sl_s_Client
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

      _rx = /\bundefined method `montoya_from_agent'/

      begin
        listener.maybe_receive_event :montoya, :_no_see_
      rescue ::NoMethodError => e
      end

      e.message =~ _rx
    end

    def build_listener
      subject_module_.suffixed client, :from_agent
    end

    def build_client
      @a = []
      X_sl_s_Client.new @a
    end
  end
end
