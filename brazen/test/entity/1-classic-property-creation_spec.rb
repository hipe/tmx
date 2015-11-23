require_relative '../test-support'

Skylab::Brazen::TestSupport.lib_( :entity ).require_common_sandbox

module Skylab::Brazen::TestSupport::Entity_Sandbox

  describe "[br] entity - 1. classic property creation" do

    context "minimal non-empty" do

      before :all do

        class Foo
          Subject_[].call self do

          def foo
          end

          end
        end
      end

      it "knows the number of properties" do

        _subject.length.should eql 1
      end

      it "knows the local normal names of the properties" do

        o = _subject
        a = o.get_names
        a.should eql [ :foo ]
        a_ = o.get_names
        ( a.object_id == a_.object_id ).should eql false
      end

      context "(property as model)" do

        it "description 1" do
          _subject.description.should eql :foo
        end

        it "description 2" do
          _subject.description_under( Home_::API.expression_agent_instance ).
            should eql "'foo'"
        end

        def _subject
          super.fetch :foo
        end
      end

      def _subject
        Foo.properties
      end
    end

    context "basic behavior of inheritence" do

      before :all do

        class Foo_Base
          Subject_[].call self do
            def foo
            end
          end
        end

        class Foo_Child < Foo_Base
          Subject_[].call self do
            def bar
            end
          end
        end
      end

      it "child inherits properties of base" do
        Foo_Base.properties.get_names.should eql [ :foo ]
        Foo_Child.properties.get_names.should eql [ :foo, :bar ]
      end

      it "the child's handle on the property is THE SAME PROPERTY" do
        foo1 = Foo_Base.properties.fetch :foo
        foo2 = Foo_Child.properties.fetch :foo
        foo1 or fail
        foo1.object_id.should eql foo2.object_id
      end
    end

    context "for now with inheritence, re-opening properties" do

      it "is something you can do" do

          class Foo_Reopener_Base
            Subject_[].call self do
            def foo
            end
            end
          end

          class Foo_Reopener_Child < Foo_Reopener_Base
            Subject_[].call self do
            def foo
            end
            end
          end

      end
    end
  end
end
