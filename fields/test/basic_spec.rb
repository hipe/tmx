require_relative 'test-support'

module Skylab::Fields::TestSupport

  describe "[fi] basic" do

    B_subject_node__ = -> do
      Home_::Basic
    end

    context "enhance your class using the iambic DSL" do

      before :all do

        class B_Foo
          B_subject_node__[].with :client, self,
            :globbing, :absorber, :initialize,
            :field_i_a, [ :ding, :bat ]
        end
      end

      let :foo do
        B_Foo.new
      end

      it "contructed with no args, your instance will have nilified ivars" do
        foo.instance_variables.sort.should eql [ :@bat, :@ding ]
      end

      it "does not, however, give you attr readers" do
        foo.respond_to?( :bat ).should eql false
        foo.class.private_method_defined?( :bat ).should eql false
      end

      it "sets *all* field ivars to nil, and then sets the values given" do
        foo = B_Foo.new( :bat, :x )
        foo.instance_variable_get( :@bat ).should eql :x
        foo.instance_variable_get( :@ding ).should eql nil
      end

      it "although it does not enforce required fields, it enforces the valid set" do

        begin
          B_Foo.new( :ding, :x, :bat, :y, :bazzle, :z )
        rescue ::KeyError => e
        end

        e.message.should match ::Regexp.new( "\\Akey\\ not\\ found:\\ :bazzle\\z" )
      end
    end

    context "when you use the \"struct like\" \"macro\"" do

      before :all do

        class B_Bar
          B_subject_node__[].with :client, self, :struct_like,
            :globbing, :absorber, :initialize,
            :field_i_a, [ :fiz, :faz ]
        end
      end

      it "you get a `members` instance method" do
        B_Bar.new.members.should eql [ :fiz, :faz ]
      end

      it "you get an attr reader and writer for each member" do
        f = B_Bar.new :faz, :hi
        f.faz.should eql :hi
        f.fiz.should eql nil
        f.faz = :horf
        f.faz.should eql :horf
        f.fiz = :heff
        f.fiz.should eql :heff
      end

      it "and you get an alias from '[]' to 'new'" do
        B_Bar[ :fiz, :hoo, :faz, :harf ].fiz.should eql :hoo
      end
    end
  end
end
