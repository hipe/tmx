require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - making an extension module" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    context "empty definition block" do

      shared_subject :_subject_module do
        _ = Entity.lib
        X_e_maem_Mod = _.call do
        end
      end

      it "with one argument (a proc), subject creates a new module" do
        _subject_module.should be_respond_to :constants
      end
    end

    context "definition block with two properties" do

      shared_subject :_subject_module do

        X_e_maem_Two = Entity.lib.call do

          def foo
            @foo_x = gets_one
            true
          end

          def bar
            @bar_x = gets_one
            true
          end

          module self::Module_Methods
            define_method :with, Entity::DEFINITION_FOR_THE_METHOD_CALLED_WITH 
          end

          include Entity::TestInstanceMethods
        end

        module X_e_maem_Two
          attr_reader :foo_x, :bar_x
        end

        class X_e_maem_Two_Child

          X_e_maem_Two.call self do

            def bar
              @has_bar = true
              super
            end

            def baz
              @baz_x = gets_one
              true
            end
          end

          attr_reader :has_bar, :baz_x
          self
        end
      end

      it "extension module both gives properties and allows new to be added" do
        foo = _subject_module.with :foo, :F, :bar, :B, :baz, :Z
        foo.has_bar.should eql true
        foo.foo_x.should eql :F
        foo.bar_x.should eql :B
        foo.baz_x.should eql :Z
      end
    end

    context "just extension with no extra" do

      shared_subject :_subject_module do

        X_e_maem_Props = Entity.lib.call do

          def uh
            @uh_x = gets_one
            true
          end

          def ah
            @ah_x = gets_one
            true
          end

          module self::Module_Methods
            define_method :with, Entity::DEFINITION_FOR_THE_METHOD_CALLED_WITH
          end

          include Entity::TestInstanceMethods
        end

        class X_e_maem_Prop_Wanter
          X_e_maem_Props[ self ]
          attr_reader :uh_x, :ah_x
          self
        end
      end

      it "ok" do
        foo = _subject_module.with :uh, :U, :ah, :A
        foo.uh_x.should eql :U
        foo.ah_x.should eql :A
      end
    end

    context "diamond" do

      shared_subject :_subject_module do

        X_e_maem_Left = Entity.lib.call do

          def one
            @one_x = gets_one
            true
          end

          def two
            @one_x = gets_one
            true
          end
        end

        X_e_maem_Right = Entity.lib.call do

          def two
            @two_x = gets_one.to_s.upcase.intern
            true
          end

          def three
            @three_x = gets_one
            true
          end
        end

        class X_e_maem_Mid
          X_e_maem_Left[ self ]
          X_e_maem_Right[ self ]
          attr_reader :one_x, :two_x, :three_x
          Entity::Enhance_for_test[ self ]
        end
      end

      it "ok - overriding is order dependant" do
        foo = _subject_module.with :one, :_one_, :two, :_two_, :three, :_three_
        foo.one_x.should eql :_one_
        foo.two_x.should eql :_TWO_
        foo.three_x.should eql :_three_
      end
    end

    # ==
    # ==
  end
end
