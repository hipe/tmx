require_relative 'test-support'

module Skylab::MetaHell::TestSupport::FUN::Fields_

  ::Skylab::MetaHell::TestSupport::FUN[ self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::FUN::Fields_" do
    context "using the basic fields facility out of the box only gives you" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          class Foo
            MetaHell::FUN.fields[ self, :ding, :bat ]
          end
        end
      end
      it "a readable way to set instance variables via a constructor" do
        Sandbox_1.with self
        module Sandbox_1
          (( FOO = Foo.new )).instance_variables.sort.should eql( [ :@bat, :@ding ] )
        end
      end
      it "it does not, however, give you attr readers" do
        Sandbox_1.with self
        module Sandbox_1
          FOO.respond_to?( :bat ).should eql( false )
          FOO.class.private_method_defined?( :bat ).should eql( false )
        end
      end
      it "it sets *all* field ivars to nil, and then sets the values given" do
        Sandbox_1.with self
        module Sandbox_1
          foo = Foo.new( :bat, :x )
          foo.instance_variable_get( :@bat ).should eql( :x )
          foo.instance_variable_get( :@ding ).should eql( nil )
        end
      end
      it "although it does not enforce required fields, it enforces the valid set" do
        Sandbox_1.with self
        module Sandbox_1
          -> do
            Foo.new( :ding, :x, :bat, :y, :bazzle, :z )
          end.should raise_error( KeyError,
                       ::Regexp.new( "\\Akey\\ not\\ found:\\ :bazzle\\z" ) )
        end
      end
    end
  end
end
