require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] proxy - makers - tee" do

    TS_[ self ]

    context "let's construct a tee for the methods `push` and `shift`" do

      it "send it a messsage not in the list - raises" do

        tee = build_tee_instance

        expect( -> do
          tee.class
        end ).to raise_error ::NoMethodError, /\Aundefined method `class'/
      end

      it "send it a message in the list (no upstreams), result is nil" do

        expect( build_tee_instance.push ).to be_nil

      end

      it "money - add downstreams to the tee with []=" do

        a = [] ; a_ = []
        tee = build_tee_instance

        tee[ :nerk ] = a
        tee[ :derk ] = a_

        a_.push :hi

        x = tee.push :one
        expect( x.object_id ).to eql a.object_id

        expect( a ).to eql [ :one ]
        expect( a_ ).to eql [ :hi, :one ]

        x = tee.shift
        expect( x ).to eql :one

        expect( a ).to eql EMPTY_A_
        expect( a_ ).to eql [ :one ]

      end

      it "responds to respond_to?" do
        one = build_tee_instance
        expect( one.respond_to?( :not ) ).to eql false
        expect( one.respond_to?( :push ) ).to eql true
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
