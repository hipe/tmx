require_relative 'test-support'

module Skylab::MetaHell::TestSupport::BasicFields

  describe "[mh] BasicFields" do
    context "the basic fields facility out of the box is a low-frills, low-level" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          class Foo
            MetaHell_::Basic_Fields.with :client, self,
              :globbing, :absorber, :initialize,
              :field_i_a, [ :ding, :bat ]
          end
        end
      end
      it "\"iambic\"-looking lists (either globbed or not globbed depending on you)." do
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
    context "when you use the \"struct like\" \"macro\"," do
      Sandbox_2 = Sandboxer.spawn
      before :all do
        Sandbox_2.with self
        module Sandbox_2
          class Foo
            MetaHell_::Basic_Fields.with :client, self, :struct_like,
              :globbing, :absorber, :initialize,
              :field_i_a, [ :fiz, :faz ]
          end
        end
      end
      it "you get a `members` instance method" do
        Sandbox_2.with self
        module Sandbox_2
          Foo.new.members.should eql( [ :fiz, :faz ] )
        end
      end
      it "you get an attr reader and writer for each member" do
        Sandbox_2.with self
        module Sandbox_2
          f = Foo.new :faz, :hi
          f.faz.should eql( :hi )
          f.fiz.should eql( nil )
          f.faz = :horf
          f.faz.should eql( :horf )
          f.fiz = :heff
          f.fiz.should eql( :heff )
        end
      end
      it "and you get an alias from '[]' to 'new'" do
        Sandbox_2.with self
        module Sandbox_2
          Foo[ :fiz, :hoo, :faz, :harf ].fiz.should eql( :hoo )
        end
      end
    end
  end
end
