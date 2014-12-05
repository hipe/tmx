require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity property: `property`" do

    context "there are at least 5 ways of creating monadic iambic props" do

      it "1)  the classic form with method definitions as iambic writers" do

        class P_Classic

          Subject_[].call self do

            def foo
              @foo = iambic_property
              true
            end

            def bar
              @bar = iambic_property
              true
            end
          end

          Enhance_for_test_[ self ]
        end

        expect P_Classic
      end

      it "2)  in the '[]' with the 'property' keyword" do

        class P_Simplest
          Subject_[][ self, :property, :foo, :property, :bar ]
          Enhance_for_test_[ self ]
        end

        expect P_Simplest
      end

      it "3)  in the '[]' with the 'properties' keyword" do

        class P_Props_3
          Subject_[][ self, :properties, :foo, :bar ]
          Enhance_for_test_[ self ]
        end

        expect P_Props_3
      end

      it "4)  in the '-> { }' with the 'property' keyword" do

        class P_In_Block

          Subject_[].call self do
            o :property, :foo
            o :property, :bar
          end

          Enhance_for_test_[ self ]
        end

        expect P_In_Block
      end

      it "4b) in the '-> { }' with the 'property' keyword (one line)" do

        class P_In_Block_B

          Subject_[].call self do
            o :property, :foo, :property, :bar
          end

          Enhance_for_test_[ self ]
        end

        expect P_In_Block_B
      end

      it  "5)  in the '-> { }' with the 'properties' keyword" do

        class P_In_Block_Props

          Subject_[].call self do
            o :properties, :foo, :bar
          end

          Enhance_for_test_[ self ]
        end

        expect P_In_Block_Props
      end

      it "6) re-use properties with 'reuse'" do

        class P_Reuse_Source
          Subject_[].call self do
            o :property, :bar,
              :property, :foo
          end
        end

        class P_Reuse
          Subject_[].call self do
            o :reuse, P_Reuse_Source.properties.at( :foo, :bar )
          end
          Enhance_for_test_[ self ]
        end

        expect P_Reuse
      end

      def expect cls
        subj = cls.new { }
        subj.process_fully :foo, :x, :bar, :y
        subj.instance_variable_get( :@foo ).should eql :x
        subj.instance_variable_get( :@bar ).should eql :y
      end
    end
  end
end
