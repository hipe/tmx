require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] proxy - makers - tee" do

    extend TS_

    context "let's construct a tee for the methods `push` and `shift`" do

      it "send it a messsage not in the list - raises" do

        tee = build_tee_instance

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

        a.should eql EMPTY_A_
        a_.should eql [ :one ]

      end

      it "responds to respond_to?" do
        one = build_tee_instance
        one.respond_to?( :not ).should eql false
        one.respond_to?( :push ).should eql true
      end

      def build_tee_instance
        __class.new
      end

      dangerous_memoize_ :__class do
        TS_::Prxy_Makers_Tee_01 = Home_::Proxy::Makers::Tee.new :push, :shift
      end
    end
  end
end
