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
        expect( on.value ).to eql :B
      end

      it "the output node reports the index of the winning node" do
        expect( on.constituent_index ).to eql 1
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
        expect( ( p[ :a ].value ) ).to eql :A
      end

      it "and another" do
        expect( ( p[ :b ].value ) ).to eql :B
        expect( ( p[ :c ] ) ).to eql nil
      end
    end

    it "in the minimal case, the empty parser always results in nil" do
      g = Home_.function( :alternation ).with :functions
      expect( g.output_node_via_single_token_value( :bizzie ) ).to eql nil
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
        expect( ( p[ :will, :not, :parse ] ) ).to eql nil
      end

      it "parses one" do
        expect( ( p[ :one ].value ) ).to eql :is_one
      end

      it "parses two" do
        expect( ( p[ :two ].constituent_index ) ).to eql 1
      end

      it "but it won't parse two after one" do
        expect( ( p[ :one, :two ] ) ).to eql nil
      end
    end
  end
end
