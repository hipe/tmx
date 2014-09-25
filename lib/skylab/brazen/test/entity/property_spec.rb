require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity property: `property`" do

    context "there are at least 5 ways of creating monadic iambic props" do

      it "1)  the classic form with method definitions as iambic writers" do

        class P_Classic
          Subject_[][ self, -> do
            def foo
              @foo = iambic_property
            end
            def bar
              @bar = iambic_property
            end
          end ]
        end
        expect P_Classic
      end

      it "2)  in the '[]' with the 'property' keyword" do

        class P_Simplest
          Subject_[][ self, :property, :foo, :property, :bar ]
        end
        expect P_Simplest
      end

      it "3)  in the '[]' with the 'properties' keyword" do

        class P_Props_3
          Subject_[][ self, :properties, :foo, :bar ]
        end
        expect P_Props_3
      end

      it "4)  in the '-> { }' with the 'property' keyword" do

        class P_In_Block
          Subject_[][ self, -> do
            o :property, :foo
            o :property, :bar
          end ]
        end
        expect P_In_Block
      end

      it "4b) in the '-> { }' with the 'property' keyword (one line)" do

        class P_In_Block_B
          Subject_[][ self, -> do
            o :property, :foo, :property, :bar
          end ]
        end
        expect P_In_Block_B
      end

      it  "5)  in the '-> { }' with the 'properties' keyword" do
        class P_In_Block_Props
          Subject_[][ self, -> do
            o :properties, :foo, :bar
          end ]
        end
        expect P_In_Block_Props
      end

      it "5b) in the '-> { }' with the 'properties' keyword (2 lines)" do
        class P_In_Block_Props_B
          Subject_[][ self, -> do
            o :properties, :foo
            o :bar
          end ]
        end
        expect P_In_Block_Props_B
      end

      it "6) re-use properties with 'reuse'" do
        class P_Reuse_Source
          Subject_[][ self, -> do
            o :property, :bar,
              :property, :foo
          end ]
        end
        class P_Reuse
          Subject_[][ self, -> do
            o :reuse, P_Reuse_Source.properties.at( :foo, :bar )
          end ]
        end
        expect P_Reuse
      end

      def expect cls
        subj = cls.new.send :with, :foo, :x, :bar, :y
        subj.instance_variable_get( :@foo ).should eql :x
        subj.instance_variable_get( :@bar ).should eql :y
      end
    end
  end
end
