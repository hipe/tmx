require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Basic_Fields

  describe "[mh] Basic_Fields" do

    context "enhance your class using the iambic DSL" do

      before :all do
        class Foo
          MetaHell_::Basic_Fields.with :client, self,
            :globbing, :absorber, :initialize,
            :field_i_a, [ :ding, :bat ]
        end
      end

      let :foo do
        Foo.new
      end
      it "contructed with no args, your instance will have nilified ivars" do
        foo.instance_variables.sort.should eql [ :@bat, :@ding ]
      end
      it "does not, however, give you attr readers" do
        foo.respond_to?( :bat ).should eql false
        foo.class.private_method_defined?( :bat ).should eql false
      end
      it "sets *all* field ivars to nil, and then sets the values given" do
        foo = Foo.new( :bat, :x )
        foo.instance_variable_get( :@bat ).should eql :x
        foo.instance_variable_get( :@ding ).should eql nil
      end
      it "although it does not enforce required fields, it enforces the valid set" do
        -> do
          Foo.new( :ding, :x, :bat, :y, :bazzle, :z )
        end.should raise_error( KeyError,
                     ::Regexp.new( "\\Akey\\ not\\ found:\\ :bazzle\\z" ) )
      end
    end
    context "when you use the \"struct like\" \"macro\"" do

      before :all do
        class Bar
          MetaHell_::Basic_Fields.with :client, self, :struct_like,
            :globbing, :absorber, :initialize,
            :field_i_a, [ :fiz, :faz ]
        end
      end
      it "you get a `members` instance method" do
        Bar.new.members.should eql [ :fiz, :faz ]
      end
      it "you get an attr reader and writer for each member" do
        f = Bar.new :faz, :hi
        f.faz.should eql :hi
        f.fiz.should eql nil
        f.faz = :horf
        f.faz.should eql :horf
        f.fiz = :heff
        f.fiz.should eql :heff
      end
      it "and you get an alias from '[]' to 'new'" do
        Bar[ :fiz, :hoo, :faz, :harf ].fiz.should eql :hoo
      end
    end
    it "`iambic_detect` is a hack to peek into an iambic array" do
      a = [ :one, 'two', :three, 'four' ]
      MetaHell_::Basic_Fields.iambic_detect[ :three, a ].should eql 'four'
    end
  end
end
