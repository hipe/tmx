require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - concerns - meta-property - core" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    it "(sneak ahead to an essential case)" do

        class X_e_mp_c_Sneak
          Entity.lib.call self do
            o :argument_arity, :zero, :meta_property, :requored,
              :requored, :property, :wazoozle,
              :property, :foozle
          end
        end

        _a = X_e_mp_c_Sneak.properties.reduce_by do |prp|
          prp.requored
        end.to_a

        _a.length.should eql 1
        prp = _a.first
        prp.name_symbol.should eql :wazoozle
    end

    context "create arbitrary meta-properties and use them in the properties" do

      shared_subject :_subject_module do

        class X_e_mp_c_Foo

          Entity.lib.call self do
            o :meta_property, :fun_ness
            o :fun_ness, :really_fun, :property, :foo
          end

          Entity::Define_common_initialize_and_with[ self ]
        end
      end

      it "still works as a property ofc" do
        want_works_as_property _subject_module
      end

      it "reflect with your meta-properties" do
        want_reflects _subject_module
      end
    end

    context "if your iambic writer is defined classically, works the same" do

      shared_subject :_subject_module do

        class X_e_mp_c_Bar

          Entity.lib.call self do

            o :meta_property, :fun_ness
            o :fun_ness, :really_fun

            def foo
              @foo = gets_one
            end
          end

          Entity::Define_common_initialize_and_with[ self ]
        end
      end

      it "works as property" do
        want_works_as_property _subject_module
      end

      it "reflects" do
        want_reflects _subject_module
      end
    end

    def want_works_as_property cls
      foo = cls.with :foo, :bar
      foo.instance_variable_get( :@foo ).should eql :bar
    end

    def want_reflects cls
      cls.properties[ :foo ].fun_ness.should eql :really_fun
    end
  end
end
