require_relative '../../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - alternation" do

    it "the output node reports the winning index. can be called inline." do
      on = subject_parse_module_.with(
        :input_array, [ :b ],
        :functions,
          :trueish_single_value_mapper, -> x { :a == x and :A },
          :trueish_single_value_mapper, -> x { :b == x and :B } )

      on.value_x.should eql :B
      on.constituent_index.should eql 1
    end
    context "you can curry the parser separately" do

      before :all do
        P = subject_parse_module_.new_with(
          :functions,
            :trueish_single_value_mapper, -> x { :a == x and :A },
            :trueish_single_value_mapper, -> x { :b == x and :B } ).
        method( :output_node_via_single_token_value )
      end
      it "and call it in another" do
        P[ :a ].value_x.should eql :A
      end
      it "and another" do
        P[ :b ].value_x.should eql :B
        P[ :c ].should eql nil
      end
    end
    it "in the minimal case, the empty parser always results in nil" do
      g = subject_parse_module_.new_with :functions
      g.output_node_via_single_token_value( :bizzie ).should eql nil
    end
    context "maintaining parse state (artibrary extra arguments)" do

      before :all do
        g = subject_parse_module_.new_with(
          :functions,
            :trueish_single_value_mapper, -> x { :one == x and :is_one },
            :trueish_single_value_mapper, -> x { :two == x and :is_two } )
        P_ = -> * x_a do
          g.output_node_via_input_array_fully x_a
        end
      end
      it "parses none" do
        P_[ :will, :not, :parse ].should eql nil
      end
      it "parses one" do
        P_[ :one ].value_x.should eql :is_one
      end
      it "parses two" do
        P_[ :two ].constituent_index.should eql 1
      end
      it "but it won't parse two after one" do
        P_[ :one, :two ].should eql nil
      end
    end

    def self.subject_parse_module_
      Home_.function :alternation
    end

    def subject_parse_module_
      self.class.subject_parse_module_
    end
  end
end
