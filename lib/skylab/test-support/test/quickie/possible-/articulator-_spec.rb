require_relative 'test-support'

module Skylab::TestSupport::TestSupport::Quickie::Possible_::Articulator_

  ::Skylab::TestSupport::TestSupport::Quickie::Possible_[ self ]

  include CONSTANTS

  TestSupport = ::Skylab::TestSupport

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::TestSupport::Quickie::Possible_::Articulator_" do
    context "this generates a simple articulator class." do
      Sandbox_1 = Sandboxer.spawn
      it "one way to use it is like so" do
        Sandbox_1.with self
        module Sandbox_1
          Wing_Wang_Predicate = Articulator_.
            new( :wing, :wang, -> do
              "wing is: #{ @wing }, wang: #{ @wang }"
            end )

          ( obj = Wing_Wang_Predicate.new 'DING', 'DANG' ).wing.should eql( 'DING' )
          obj.wang.should eql( 'DANG' )
          obj.instance_exec( & obj.articulation_proc ).should eql( "wing is: DING, wang: DANG" )
        end
      end
    end
    context "another way to manage your signature is to pass the same fields" do
      Sandbox_2 = Sandboxer.spawn
      it "then you can use `articulate_self`" do
        Sandbox_2.with self
        module Sandbox_2
          P = Articulator_.new( :a, :b, -> a, b { "#{ a } + #{ b }" } )
          P[ "one", "two" ].articulate_self.should eql( "one + two" )
        end
      end
    end
    context "a shorthand way to accomplish the above is by" do
      Sandbox_3 = Sandboxer.spawn
      it "defining an articulator with ony one function" do
        Sandbox_3.with self
        module Sandbox_3
          P = Articulator_[ -> a, b do
            "#{ a } + #{ b }"
          end ]

          P[ "one", "two" ].articulate_self.should eql( "one + two" )
        end
      end
    end
    context "other times you might do clever things with the rendering context" do
      Sandbox_4 = Sandboxer.spawn
      it "like so" do
        Sandbox_4.with self
        module Sandbox_4
          Error_Predicate = Articulator_.new(
            :name, :val, -> o do
              n, v = o.at :name, :val
              "#{ n } had a #{ em 'bad' } issue - #{ v }"
            end )

          err = Error_Predicate.new 'I', 'burnout'

          o = ::Object.new
          def o.em s ; "__#{ s.upcase }__" end

          exp = "I had a __BAD__ issue - burnout"
          ( o.instance_exec err, & err.articulation_proc ).should eql( exp )
        end
      end
    end
    context "write your proc signature however you like, e.g use `to_a`" do
      Sandbox_5 = Sandboxer.spawn
      it "like so" do
        Sandbox_5.with self
        module Sandbox_5
          P = Articulator_.new :up, :down, -> up, down do
            "#{ up } and #{ down }"
          end

          p = P.new( 'hi', 'lo' )
          p.articulation_proc[ * p.to_a ].should eql( 'hi and lo' )
        end
      end
    end
    context "articulators have a stupid simple but powerful algorithm for inflection" do
      Sandbox_6 = Sandboxer.spawn
      it "like so" do
        Sandbox_6.with self
        module Sandbox_6
          NP = Articulator_[ :a, -> a { a * ' and ' } ]
          VP = Articulator_[ :tense, :a, -> t, a do
            :present == t ? ( 1 == a.length ? 'has' : 'have' ) : 'had'
          end ]

          ( NP[ [ 'jack' ] ] | VP[ :present ] ).inflect.should eql( "jack has" )

          ( NP[ %w(Jack Jill) ] | VP[ :present ] ).inflect.should eql( "Jack and Jill have" )

          ( NP[ %w( Jack ) ] | VP[ :past ] ).inflect.should eql( "Jack had" )
        end
      end
    end
  end
end
