require_relative '../../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - alternation" do

    TS_[ self ]
    use :memoizer_methods

    context "the output node reports the winning index. can be called inline." do

      shared_subject :on do
        on = Home_.function( :alternation ).via(
          :input_array, [ :b ],
          :functions,
            :trueish_single_value_mapper, -> x { :a == x and :A },
            :trueish_single_value_mapper, -> x { :b == x and :B } )

        on
      end

      it "the output node has the winning value" do
        on.value_x.should eql :B
      end

      it "the output node reports the index of the winning node" do
        on.constituent_index.should eql 1
      end
    end

    context "you can curry the parser separately" do

      shared_subject :p do
        p = Home_.function( :alternation ).with(
          :functions,
            :trueish_single_value_mapper, -> x { :a == x and :A },
            :trueish_single_value_mapper, -> x { :b == x and :B } ).
        method( :output_node_via_single_token_value )

        p
      end

      it "and call it in another" do
        ( p[ :a ].value_x ).should eql :A
      end

      it "and another" do
        ( p[ :b ].value_x ).should eql :B
        ( p[ :c ] ).should eql nil
      end
    end

    it "in the minimal case, the empty parser always results in nil" do
      g = Home_.function( :alternation ).with :functions
      g.output_node_via_single_token_value( :bizzie ).should eql nil
    end

    context "maintaining parse state (artibrary extra arguments)" do

      shared_subject :p do
        g = Home_.function( :alternation ).with(
          :functions,
            :trueish_single_value_mapper, -> x { :one == x and :is_one },
            :trueish_single_value_mapper, -> x { :two == x and :is_two } )

        p = -> * x_a do
          g.output_node_via_input_array_fully x_a
        end

        p
      end

      it "parses none" do
        ( p[ :will, :not, :parse ] ).should eql nil
      end

      it "parses one" do
        ( p[ :one ].value_x ).should eql :is_one
      end

      it "parses two" do
        ( p[ :two ].constituent_index ).should eql 1
      end

      it "but it won't parse two after one" do
        ( p[ :one, :two ] ).should eql nil
      end
    end
  end
end
