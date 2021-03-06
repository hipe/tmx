require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - core modifiers" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    it "minimal" do

        class X_e_cm_Minimal

          Entity.lib.call self do

            o :argument_scanning_writer_method_name_suffix, :_ZOINK

            def foo_bar_ZOINK
              @foo_bar = gets_one
            end

          end

          Entity::Enhance_for_test[ self ]
        end

      obj = X_e_cm_Minimal.with :foo_bar, :xyz
      expect( obj.instance_variable_get :@foo_bar ).to eql :xyz
    end

    it "with two (together)" do

        class X_e_cm_With_Two

          Entity.lib.call self do

            o :argument_scanning_writer_method_name_suffix, :_ZEE

            def foo_ZEE
              @foo = gets_one
            end

            o :argument_scanning_writer_method_name_suffix, :_ZOO

            def bar_ZOO
              @bar = gets_one
            end

            def baz_ZOO
              @baz = gets_one
            end
          end

          Entity::Enhance_for_test[ self ]
        end

      obj = X_e_cm_With_Two.with :foo, :F, :bar, :B, :baz, :Z
      a = obj.instance_exec do
        [ :foo, :bar, :baz ].map do |i|
          instance_variable_get :"@#{ i }"
        end
      end
      expect( a ).to eql [ :F, :B, :Z ]
    end

    # ==
    # ==
  end
end
