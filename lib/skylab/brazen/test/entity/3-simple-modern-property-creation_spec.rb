require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity 3. simple modern property creation" do

    context "there are at least 5 ways of creating monadic iambic props" do

      it "1)  the classic form with method definitions as iambic writers" do

        class P_Classic

          Subject_[].call self do

            def foo
              @foo = gets_one_polymorphic_value
              true
            end

            def bar
              @bar = gets_one_polymorphic_value
              true
            end
          end

          Enhance_for_test_[ self ]
        end

        _expect P_Classic
      end

      it "2)  in the '[]' with the 'property' keyword" do

        class P_Simplest
          Subject_[][ self, :property, :foo, :property, :bar ]
          Enhance_for_test_[ self ]
        end

        _expect P_Simplest
      end

      it "3)  in the '[]' with the 'properties' keyword" do

        class P_Props_3
          Subject_[][ self, :properties, :foo, :bar ]
          Enhance_for_test_[ self ]
        end

        _expect P_Props_3
      end

      it "4)  in the '-> { }' with the 'property' keyword" do

        class P_In_Block

          Subject_[].call self do
            o :property, :foo
            o :property, :bar
          end

          Enhance_for_test_[ self ]
        end

        _expect P_In_Block
      end

      it "4b) in the '-> { }' with the 'property' keyword (one line)" do

        class P_In_Block_B

          Subject_[].call self do
            o :property, :foo, :property, :bar
          end

          Enhance_for_test_[ self ]
        end

        _expect P_In_Block_B
      end

      it  "5)  in the '-> { }' with the 'properties' keyword" do

        class P_In_Block_Props

          Subject_[].call self do
            o :properties, :foo, :bar
          end

          Enhance_for_test_[ self ]
        end

        _expect P_In_Block_Props
      end

      it "6) re-use properties with 'reuse'" do

        class P_Reuse_Multiple

          Subject_[].call self,
            :reuse, P_reuse_source__[].properties.at( :foo, :bar )

          Enhance_for_test_[ self ]
        end

        _expect P_Reuse_Multiple
      end

      it "7) like (6) but only one object" do

        class P_Reuse_One

          bx = P_reuse_source__[].properties

          Subject_[].call self,

            :property_object, bx.fetch( :foo ),
            :property_object, bx.fetch( :bar )

          Enhance_for_test_[ self ]
        end

        _expect P_Reuse_One
      end

      P_reuse_source__ = Callback_.memoize do

        class P_Reuse_Source

          Subject_[].call self,
            :property, :bar,
            :property, :foo

          self
        end
      end

      def _expect cls
        subj = cls.new { }
        subj.process_fully_for_test_ :foo, :x, :bar, :y
        subj.instance_variable_get( :@foo ).should eql :x
        subj.instance_variable_get( :@bar ).should eql :y
      end
    end
  end
end
