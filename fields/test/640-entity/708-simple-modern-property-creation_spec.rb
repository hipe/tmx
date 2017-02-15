require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - simple modern property creation" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    context "there are at least 5 ways of creating monadic iambic props" do

      it "1)  the classic form with method definitions as iambic writers" do

        class X_e_smpc_Classic

          Entity.lib.call self do

            def foo
              @foo = gets_one_polymorphic_value
              true
            end

            def bar
              @bar = gets_one_polymorphic_value
              true
            end
          end

          Entity::Enhance_for_test[ self ]
        end

        _expect X_e_smpc_Classic
      end

      it "2)  in the '[]' with the 'property' keyword" do

        class X_e_smpc_Simplest
          Entity.lib[ self, :property, :foo, :property, :bar ]
          Entity::Enhance_for_test[ self ]
        end

        _expect X_e_smpc_Simplest
      end

      it "3)  in the '[]' with the 'properties' keyword" do

        class X_e_smpc_Props_3
          Entity.lib[ self, :properties, :foo, :bar ]
          Entity::Enhance_for_test[ self ]
        end

        _expect X_e_smpc_Props_3
      end

      it "4)  in the '-> { }' with the 'property' keyword" do

        class X_e_smpc_In_Block

          Entity.lib.call self do
            o :property, :foo
            o :property, :bar
          end

          Entity::Enhance_for_test[ self ]
        end

        _expect X_e_smpc_In_Block
      end

      it "4b) in the '-> { }' with the 'property' keyword (one line)" do

        class X_e_smpc_In_Block_B

          Entity.lib.call self do
            o :property, :foo, :property, :bar
          end

          Entity::Enhance_for_test[ self ]
        end

        _expect X_e_smpc_In_Block_B
      end

      it  "5)  in the '-> { }' with the 'properties' keyword" do

        class X_e_smpc_In_Block_Props

          Entity.lib.call self do
            o :properties, :foo, :bar
          end

          Entity::Enhance_for_test[ self ]
        end

        _expect X_e_smpc_In_Block_Props
      end

      it "6) re-use properties with 'reuse'" do

        class X_e_smpc_Reuse_Multiple

          Entity.lib.call self,
            :reuse, X_e_smpc_reuse_source__[].properties.at( :foo, :bar )

          Entity::Enhance_for_test[ self ]
        end

        _expect X_e_smpc_Reuse_Multiple
      end

      it "7) like (6) but only one object" do

        class X_e_smpc_Reuse_One

          bx = X_e_smpc_reuse_source__[].properties

          Entity.lib.call self,

            :property_object, bx.fetch( :foo ),
            :property_object, bx.fetch( :bar )

          Entity::Enhance_for_test[ self ]
        end

        _expect X_e_smpc_Reuse_One
      end

      X_e_smpc_reuse_source__ = Lazy_.call do

        class X_e_smpc_Reuse_Source

          Entity.lib.call self,
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

    # ==
    # ==
  end
end
