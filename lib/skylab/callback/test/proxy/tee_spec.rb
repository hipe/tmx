require_relative 'test-support.rb'

module Skylab::Callback::TestSupport::Proxy::Tee

  ::Skylab::Callback::TestSupport::Proxy[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

end

module Skylab::Callback::TestSupport::Proxy::Tee

  describe "[cb] proxy tee" do

    extend TS_

    context "let's construct a tee for the methods `push` and `shift`" do

      before :all do

        One = Subject_[].new :push, :shift

      end

      it "send it a messsage not in the list - raises" do

        tee  = build_tee_instance

        -> do
          tee.class
        end.should raise_error ::NoMethodError, /\Aundefined method `class'/
      end

      it "send it a message in the list (no upstreams), result is nil" do

        build_tee_instance.push.should be_nil

      end

      it "money - add downstreams to the tee with []=" do

        a = [] ; a_ = []
        tee = build_tee_instance

        tee[ :nerk ] = a
        tee[ :derk ] = a_

        a_.push :hi

        x = tee.push :one
        x.object_id.should eql a.object_id

        a.should eql [ :one ]
        a_.should eql [ :hi, :one ]

        x = tee.shift
        x.should eql :one

        a.should eql Callback_::EMPTY_A_
        a_.should eql [ :one ]

      end

      it "responds to respond_to?" do
        one = build_tee_instance
        one.respond_to?( :not ).should eql false
        one.respond_to?( :push ).should eql true
      end

      def build_tee_instance
        One.new
      end
    end

    Subject_ = -> do
      Callback_::Proxy::Tee
    end
  end
end
