require_relative 'methodic/test-support'

module Skylab::Callback::TestSupport::Actor::Methodic

  describe "[cb] actors - methodic" do

    context "with three" do

      before :all do

        class Foo_Basic

          Parent_subject_[].methodic self, :properties,
            :jiang, :xiao, :qing

          attr_reader :jiang, :xiao, :qing, :x_a

          Enhance_for_test_[ self ]
        end
      end

      it "loads" do
      end

      it "passive - ok on empty array. when no iambic remainder, result is true" do
        x = foo.process_passively
        x.should eql true
      end

      it "passive - parses a subset ('fully')" do
        foo = self.foo
        x = foo.process_passively :jiang, :J, :qing, :Q
        foo.jiang.should eql :J
        foo.qing.should eql :Q
        x.should eql true
      end

      it "order does not matter (for contiguous recognized terms)" do
        foo = self.foo
        x = foo.process_passively :qing, :Q, :xiao, :X
        foo.qing.should eql :Q
        foo.xiao.should eql :X
        x.should eql true
      end

      it "passive - succeeds but stops at first unrec arg. stream reflects this" do
        foo = self.foo
        st = foo.iambic_stream_via_iambic_array [ :xiao, :X, :wuu, :jiang, :J ]
        x = foo.process_iambic_stream_passively st
        x.should eql true
        foo.xiao.should eql :X
        foo.jiang.should be_nil
        st.current_index.should eql 2
      end

      let :foo do
        Foo_Basic.new
      end

      it "when 'fully' - works with subset" do
        foo = self.foo
        x = foo.process_fully :jiang, :J, :xiao, :X
        foo.jiang.should eql :J
        foo.xiao.should eql :X
        x.should eql true
      end

      it "when 'fully' - unrecognzied term results in argument error" do
        foo = self.foo
        _rx = %r(\Aunrecognized property 'leung')
        -> do
          foo.process_fully :xiao, :X, :leung, :_never_see_
        end.should raise_error ::ArgumentError, _rx
      end
    end

    context "simple properties" do

      before :all do
        class X
          Parent_subject_[].methodic self, :simple, :properties,
            :argument_arity, :zero, :ivar, :@fz, :property, :foozie,
            :argument_arity, :one, :ivar, :@hh, :property, :he_he

          Enhance_for_test_[ self ]
        end
      end

      it "loads" do
      end

      it "normal" do
        x = X.new
        x.process_fully :foozie, :he_he, :hi
        x.instance_variable_get( :@hh ).should eql :hi
        x.instance_variable_get( :@fz ).should eql true
      end

      it "nilifies" do
        x = X.new do
          nilify_uninitialized_ivars
        end
        x.instance_variable_defined?( :@hh ).should eql true
        x.instance_variable_defined?( :@fz ).should eql true
      end
    end

    context "`ignore`" do

      before :all do
        class X_2
          Parent_subject_[].methodic self, :simple, :properties,
            :ignore, :property, :foo,
            :property, :bar

          Enhance_for_test_[ self ]
        end
      end

      it "ignores" do
        x = X_2.new do
          process_fully :foo, :_no_see_, :bar, :BAR
        end
        x.instance_variables.include?( :@foo ).should eql false
        x.instance_variable_get( :@bar ).should eql :BAR
      end
    end

    context "`properties` (again) works like elsewhere, a flat list" do

      before :all do
        class Y
          Parent_subject_[].methodic self, :simple, :properties,
            :properties, :One, :t_w_o, :three

        end
      end

      it "the remaining symbols in the input are each treated as 1 name" do
        _i_a = Y.properties.get_names
        _i_a.should eql [ :One, :t_w_o, :three ]
      end
    end

    context "`properties` works even if you use keywords for names" do

      before :all do
        class Y_2
          Parent_subject_[].methodic self, :simple, :properties,
            :properties, :argument_artiy, :parameter_arity
        end
      end

      it "ok" do
        _i_a = Y_2.properties.get_names
        _i_a.should eql [ :argument_artiy, :parameter_arity ]
      end
    end

    context "you can use keywords as field names b.c of mandatory `property` keyword" do

      before :all do
        class Z
          Parent_subject_[].methodic self, :simple, :properties,
            :property, :wizzie,
            :argument_arity, :zero, :property, :wazzie,
            :argument_arity, :one, :property, :argument_arity
        end
      end

      it "this future-proofs you from meta-properties you haven't written yet " do
        _i_a = Z.properties.get_names
        _i_a.should eql [ :wizzie, :wazzie, :argument_arity ]
        _prop = Z.properties.fetch( :argument_arity )
        _prop.argument_arity.should eql :one
      end
    end

    context "with minimal (NOT simple) - bridging the inheritence divide" do

      before :all do

        module A_1
          Parent_subject_[].methodic self, :properties, :property, :x
        end

        class A_2
          include A_1
          Enhance_for_test_[ self ]
        end
      end

      it "a class can mix-in moodules which gives it the private foo= methods" do
        a2 = A_2.new
        a2.process_fully :x, :hi
        a2.instance_variable_get( :@x ).should eql :hi
      end
    end

    context "with `simple`, AMAZINGLY bridging the module inheritence half-works:" do

      before :all do

        module B_1
          Parent_subject_[].methodic self, :simple, :properties, :property, :x
        end

        class B_2
          include B_1
          Enhance_for_test_[ self ]
        end
      end

      it "just using it to parse instance iambic will work" do
        b = B_2.new
        b.process_fully :x, :y
        b.instance_variable_get( :"@x" ).should eql :y
      end

      it "but it will bork if you try to do something that needs reflection" do
        -> do
          B_2.new do
            nilify_uninitialized_ivars
          end
        end.should raise_error ::NoMethodError, %r(\Aundefined method `properties')
      end
    end

    context "with `simple` in a class chain, inheritence works as expected" do

      before :all do

        class C_1
          Parent_subject_[].methodic self, :simple, :properties, :property, :x
        end

        class C_2 < C_1
          Enhance_for_test_[ self ]
        end
      end

      it "(in this context the child class adds nothing)" do
        x = C_2.new
        x.process_fully :x, :y
        x.instance_variable_get( :"@x" ).should eql :y
      end

      it "things that require reflection also work" do
        o = C_2.new do
          nilify_uninitialized_ivars
        end
        o.instance_variable_defined?( :"@x" ).should eql true
      end
    end

    context "add NEW properties to the child class" do

      before :all do

        class D_1
          Parent_subject_[].methodic self, :simple, :properties, :property, :x
        end

        class D_2 < D_1
          Parent_subject_[].methodic self, :simple, :properties, :property, :z
          Enhance_for_test_[ self ]
        end
      end

      it "(in this case the child class adds one property)" do
        o = D_2.new
        o.process_fully :x, :y, :z, :A
        o.instance_variable_get( :"@x" ).should eql :y
        o.instance_variable_get( :"@z" ).should eql :A
      end

      it "reflection works" do
        D_2.properties.get_names.should eql [ :x, :z ]
      end

      it "so things that require reflection also work" do
        o = D_2.new do
          nilify_uninitialized_ivars
        end
        o.instance_variable_defined?( :"@x" ).should eql true
        o.instance_variable_defined?( :"@z" ).should eql true
      end
    end

    # it "if you try to re-open an existing property, for now it breaks"

    # context "minimal methodic actor modules can mash up in big graphs"

  end
end
