require_relative 'test-support'

module Skylab::Callback::TestSupport

  module Mmztn___  # :+#throwaway-module for constants created during tests

    # <-

  TS_.describe "[ca] memoization" do

    extend TS_

    context "'s block form" do

      context "uses the same objects, kept in a pool, for each block" do

        before :all do

          class Wat

            Home_::Memoization::Pool[ self ].
              instances_can_only_be_accessed_through_instance_sessions

            count = 0
            define_method :initialize do
              @count = ( count += 1 )
            end

            @@clear_was_called_a = []

            define_method :clear_for_pool do
              @@clear_was_called_a << @count
            end

            define_singleton_method :cwc_a do
              @@clear_was_called_a
            end

            attr_reader :count
          end
        end

        # we see that new objects are created as they are needed, and
        # that the pool is used as a stack.

        it "we see that the pool is used as a stack" do

          cls = Wat

          cls.instance_session do |o|
            o.count.should eql( 1 )
          end

          cls.instance_session do |o|
            o.count.should eql( 1 )
            cls.instance_session do |p|
              p.count.should eql( 2 )
            end
          end

          cls.instance_session do |o|
            o.count.should eql( 1 )
            cls.instance_session do |p|
              p.count.should eql( 2 )
              cls.instance_session do |q|
                q.count.should eql( 3 )
              end
            end
          end

          cls.cwc_a.should eql( [ 1, 2, 1, 3, 2, 1 ] )
        end
      end
    end

    context "'s lease-relase form" do

      it "uses `lease` and `release` to yield the same objects from a pool" do

        class How

          count = 0

          Home_::Memoization::Pool[ self ].lease_by do

            o = new( count += 1 )
            o.message = "i am the #{ count }th nerk"
            o
          end

          attr_accessor :message
          attr_reader :pessage
          attr_accessor :rando

          def initialize cnt
            @pessage = "which came after #{ cnt - 1 }"
          end

          def clear_for_pool
            # leave @pessage as-is
          end

          def say
            "#{ message } #{ pessage }"
          end
        end

        cls = How

        o1 = cls.lease
        o1.say.should eql( "i am the 1th nerk which came after 0" )
        o1.rando = :first

        o2 = cls.lease
        o2.say.should eql( "i am the 2th nerk which came after 1" )
        o2.rando = :second

        cls.release o1  # does nothing but add it back to the pool!
        o1.say.should eql( "i am the 1th nerk which came after 0" )

        o3_1 = cls.lease
        o3_1.say.should eql( "i am the 1th nerk which came after 0" )
        o3_1.rando.should eql( :first )
      end
    end
  end
# ->
  end
end
