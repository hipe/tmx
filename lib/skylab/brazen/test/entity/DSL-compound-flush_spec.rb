require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity DSL compound flush" do

    it "minimal" do

        class DCF_Minimal

          Subject_[][ self, -> do

            o :iambic_writer_method_name_suffix, :_ZOINK

            def foo_bar_ZOINK
              @foo_bar = iambic_property
            end

          end ]
        end

      obj = DCF_Minimal.new.send :with, :foo_bar, :xyz
      obj.instance_variable_get( :@foo_bar ).should eql :xyz
    end

    it "with two (together)" do

        class DCF_With_Two

          Subject_[][ self, -> do

            o :iambic_writer_method_name_suffix, :_ZEE

            def foo_ZEE
              @foo = iambic_property
            end

            o :iambic_writer_method_name_suffix, :_ZOO

            def bar_ZOO
              @bar = iambic_property
            end

            def baz_ZOO
              @baz = iambic_property
            end
          end ]
        end

      obj = DCF_With_Two.new.send :with, :foo, :F, :bar, :B, :baz, :Z
      a = obj.instance_exec do
        [ :foo, :bar, :baz ].map do |i|
          instance_variable_get :"@#{ i }"
        end
      end
      a.should eql [ :F, :B, :Z ]
    end
  end
end
