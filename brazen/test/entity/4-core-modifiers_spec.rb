require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity - 4. core modifiers" do

    it "minimal" do

        class DCF_Minimal

          Subject_[].call self do

            o :polymorphic_writer_method_name_suffix, :_ZOINK

            def foo_bar_ZOINK
              @foo_bar = gets_one_polymorphic_value
            end

          end

          Enhance_for_test_[ self ]
        end

      obj = DCF_Minimal.with :foo_bar, :xyz
      obj.instance_variable_get( :@foo_bar ).should eql :xyz
    end

    it "with two (together)" do

        class DCF_With_Two

          Subject_[].call self do

            o :polymorphic_writer_method_name_suffix, :_ZEE

            def foo_ZEE
              @foo = gets_one_polymorphic_value
            end

            o :polymorphic_writer_method_name_suffix, :_ZOO

            def bar_ZOO
              @bar = gets_one_polymorphic_value
            end

            def baz_ZOO
              @baz = gets_one_polymorphic_value
            end
          end

          Enhance_for_test_[ self ]
        end

      obj = DCF_With_Two.with :foo, :F, :bar, :B, :baz, :Z
      a = obj.instance_exec do
        [ :foo, :bar, :baz ].map do |i|
          instance_variable_get :"@#{ i }"
        end
      end
      a.should eql [ :F, :B, :Z ]
    end
  end
end
