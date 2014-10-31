require_relative 'test-support'

module Skylab::Headless::TestSupport::API::Iambics

  describe "[hl] API iambics - no frills absorption by a reflective enhancee" do

    before :all do

      class Base_No_Frills
        DSL[][ self, * DSL_method_name, :parmos ]

        parmos :important, [ :argument_arity, :zero, :ivar, :@is_important ],
               :first_name

      end

      class Child_No_Frills  < Base_No_Frills

        parmos :last_name, [ :ivar, :@last_name_s ]

        attr_reader :first_name, :last_name_s, :is_important

        def go * x_a
          nilify_and_absorb_iambic_fully x_a
        end
      end
    end

    it "o" do
      cnf = Child_No_Frills.new
      cnf.go :first_name, :Danger, :important, :last_name, :Mouse
      cnf.is_important.should eql true
      cnf.first_name.should eql :Danger
      cnf.last_name_s.should eql :Mouse
    end
  end
end
