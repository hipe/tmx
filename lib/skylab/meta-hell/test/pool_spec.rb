require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Pool

  ::Skylab::MetaHell::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module SANDBOX

  end

  MetaHell = MetaHell

  describe "#{ MetaHell }::Pool" do
    context "'s block form" do

      context "uses the same objects, kept in a pool, for each block" do

        klass = -> do
          class SANDBOX::Wat
            MetaHell::Pool.enhance( self ).with_with_instance

            count = 0
            define_method :initialize do
              @count = ( count += 1 )
            end

            @@clear_was_called_a = [ ]

            define_method :clear_for_pool do
              @@clear_was_called_a << @count
            end

            define_singleton_method :cwc_a do
              @@clear_was_called_a
            end

            attr_reader :count
          end
          ( klass = -> { SANDBOX::Wat } ).call
        end

        # we see that new objects are created as they are needed, and
        # that the pool is used as a stack.

        it "we see that the pool is used as a stack" do
          kls = klass[]

          kls.with_instance do |o|
            o.count.should eql( 1 )
          end

          kls.with_instance do |o|
            o.count.should eql( 1 )
            kls.with_instance do |p|
              p.count.should eql( 2 )
            end
          end

          kls.with_instance do |o|
            o.count.should eql( 1 )
            kls.with_instance do |p|
              p.count.should eql( 2 )
              kls.with_instance do |q|
                q.count.should eql( 3 )
              end
            end
          end

          SANDBOX::Wat.cwc_a.should eql( [ 1, 2, 1, 3, 2, 1 ] )
        end
      end
    end

    context "'s lease-relase form" do

      it "uses `lease` and `release` to yield the same objects from a pool" do

        class SANDBOX::How
          count = 0
          MetaHell::Pool.enhance( self ).with_lease_and_release -> do
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

          def say
            "#{ message } #{ pessage }"
          end
        end

        kls = SANDBOX::How

        o1 = kls.lease
        o1.say.should eql( "i am the 1th nerk which came after 0" )
        o1.rando = :first

        o2 = kls.lease
        o2.say.should eql( "i am the 2th nerk which came after 1" )
        o2.rando = :second

        kls.release o1  # does nothing but add it back to the pool!
        o1.say.should eql( "i am the 1th nerk which came after 0" )

        o3_1 = kls.lease
        o3_1.say.should eql( "i am the 1th nerk which came after 0" )
        o3_1.rando.should eql( :first )
      end
    end
  end
end
