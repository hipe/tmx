require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - classic property creation" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    context "minimal non-empty" do

      shared_subject :_subject_module do

        class X_e_cpc_Foo

          Entity.lib.call self do

          def foo
          end

          end
          self
        end
      end

      it "knows the number of properties" do

        _subject.length.should eql 1
      end

      it "knows the local normal names of the properties" do

        o = _subject
        a = o.get_keys
        a.should eql [ :foo ]
        a_ = o.get_keys
        ( a.object_id == a_.object_id ).should eql false
      end

      context "(property as model)" do

        it "description 1" do
          _subject.description.should eql :foo
        end

        it "description 2" do

          _expag = expression_agent

          _ = _subject.description_under _expag

          _.should eql "'foo'"
        end

        def _subject
          super.fetch :foo
        end
      end

      def _subject
        _subject_module.properties
      end
    end

    context "basic behavior of inheritance" do

      shared_subject :_subject_modules do

        class X_e_cpc_Base
          Entity.lib.call self do
            def foo
            end
          end
        end

        class X_e_cpc_Child < X_e_cpc_Base
          Entity.lib.call self do
            def bar
            end
          end
        end
        NIL
      end

      it "child inherits properties of base" do
        _subject_modules
        X_e_cpc_Base.properties.get_keys.should eql [ :foo ]
        X_e_cpc_Child.properties.get_keys.should eql [ :foo, :bar ]
      end

      it "the child's handle on the property is THE SAME PROPERTY" do
        _subject_modules
        foo1 = X_e_cpc_Base.properties.fetch :foo
        foo2 = X_e_cpc_Child.properties.fetch :foo
        foo1 or fail
        foo1.object_id.should eql foo2.object_id
      end
    end

    context "for now with inheritance, re-opening properties" do

      it "is something you can do" do

          class X_e_cpc_Reopener_Base
            Entity.lib.call self do
            def foo
            end
            end
          end

          class X_e_cpc_Reopener_Child < X_e_cpc_Reopener_Base
            Entity.lib.call self do
            def foo
            end
            end
          end

      end
    end

    # ==

    def expression_agent

      Entity.lib::Moniker_via_Property::THIS_EXPRESSION_AGENT___
    end

    # ==
    # ==
  end
end
