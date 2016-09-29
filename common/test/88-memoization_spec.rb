require_relative 'test-support'

module Skylab::Common::TestSupport

  describe "[co] memoization" do

    extend TS_
    use :memoizer_methods

    context "here's an example of enhancing a class with the enhancer function" do

      before :all do

        class X_m_Foo

          Home_::Memoization::Pool[ self ].instances_can_only_be_accessed_through_instance_sessions

          def initialize
            @state = :money
          end

          def clear_for_pool
            @state = :cleared
          end

          attr_reader :state
        end
      end

      it "with such a class, you can't create instances of it" do

        _rx = ::Regexp.new "\\Aprivate\\ method\\ `new'\\ called\\ for"

        begin
          X_m_Foo.new
        rescue NoMethodError => e
        end

        e.message.should match _rx
      end

      it "however you can access it during a session" do

        keep = nil
        X_m_Foo.instance_session do |o|
        (   o.state ).should eql :money
          keep = o
        end

        keep.state.should eql :cleared
      end
    end

    context "uses `lease` and `release` to yield the same objects from a pool" do

      shared_subject :_custom_tuple do

        class X_c_m_Bar

          count = 0

          Home_::Memoization::Pool[ self ].lease_by do

            o = new( count += 1 )
            o.message = "i am the #{ count }th nerk"
            o
          end

          def initialize cnt
            @pessage = "which came after #{ cnt - 1 }"
          end

          attr_writer(
            :message,
            :_object_identifier,
          )

          def clear_for_pool
            # leave @pessage as-is
          end

          def say
            "#{ @message } #{ @pessage }"
          end

          attr_reader(
            :_object_identifier,
          )
        end

        a = []
        cls = X_c_m_Bar

        o = cls.lease
        a.push o.say
        o._object_identifier = :first

        o_ = cls.lease
        a.push o_.say
        o_._object_identifier = :second

        cls.release o  # does nothing but add it back to the pool!
        a.push o.say

        o = cls.lease
        a.push o.say
        a.push o._object_identifier
        a
      end

      same = "i am the 1th nerk which came after 0"

      it "test 1" do
        _at(0) == same || fail
      end

      it "test 2" do
        _at(1) == "i am the 2th nerk which came after 1" || fail
      end

      it "test 3" do

        a = _custom_tuple
        a[2] == same || fail
        a[3] == same || fail
        a[4] == :first || fail
      end

      def _at d
        _custom_tuple.fetch d
      end
    end
  end
end
