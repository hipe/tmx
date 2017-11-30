require_relative '../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - spending pool" do

    context "unlike \"serial optionals\" and \"simple pool\", this non-terminal function" do

      before :all do
        X_f_sp_None = Home_.function( :spending_pool ).with( :functions ).to_output_node_and_mutate_array_proc
      end

      it "a parser with no nodes in it will always report 'no parse' and 'spent'" do
        expect( ( X_f_sp_None[ EMPTY_A_ ] ) ).to eql nil
      end

      it "even if the input is rando calrissian" do
        expect( ( X_f_sp_None[ :hi_mom ] ) ).to eql nil
      end
    end

    context "with parser with one node that reports it always matches & always spends" do

      before :all do
        X_f_sp_One = Home_.function( :spending_pool ).with(
          :functions,
            :proc, -> in_st do
              Home_::OutputNode.for nil
            end,
        ).to_output_node_and_mutate_array_proc
      end

      it "is always the same output node" do
        on = X_f_sp_One[ :whatever ]
        expect( on.function_is_spent ).to eql true
      end
    end

    context "with a parser with one node that reports it never matches & always spends" do

      before :all do
        X_f_sp_Spendless = Home_.function( :spending_pool ).with(
          :functions,
            :proc, -> in_st do
              nil
            end,
        ).to_output_node_and_mutate_array_proc
      end

      it "never parses" do
        expect( ( X_f_sp_Spendless[ :whatever ] ) ).to eql nil
      end
    end

    context "of 2 keywords, parse them at most once each. parse any and all digits" do

      before :all do
        X_f_sp_Digits = begin

          _NNI = Home_.function :non_negative_integer

          Home_.function( :spending_pool ).with(
          :functions,
            :keyword, "foo",
            :keyword, "bar",
            :proc, -> in_st do
              on = _NNI.output_node_via_input_stream in_st
              if on
                on.with :function_is_not_spent
              end
            end,
          ).to_output_node_and_mutate_array_proc
        end
      end

      it "does nothing with nothing" do
        expect( ( X_f_sp_Digits[ EMPTY_A_ ] ) ).to eql nil
      end

      it "parses one digit" do
        argv = [ '1' ]
        on = X_f_sp_Digits[ argv ]
        expect( argv.length ).to eql 0
        expect( on.function_is_spent ).to eql false
        kw, k2, digits = on.value
        expect( ( kw || k2 ) ).to eql nil
        expect( digits ).to eql [ 1 ]
      end

      it "parses two digits" do
        argv = %w( 2 3 )
        on = X_f_sp_Digits[ argv ]
        expect( on.function_is_spent ).to eql false
        expect( on.value ).to eql [ nil, nil, [ 2, 3 ] ]
      end

      it "parses one keyword" do
        argv = [ 'bar' ]
        on = X_f_sp_Digits[ argv ]
        expect( on.function_is_spent ).to eql false
        expect( on.value ).to eql [ nil, [:bar], nil ]
      end

      it "parses two keywords (in reverse grammar order)" do
        argv = %w( bar foo )
        on = X_f_sp_Digits[ argv ]
        expect( argv.length ).to eql 0
        expect( on.function_is_spent ).to eql false
        expect( on.value ).to eql [ [:foo], [:bar], nil ]
      end

      it "will not parse multiple of same keyword" do
        argv = %w( foo foo )
        on = X_f_sp_Digits[ argv ]
        expect( argv ).to eql %w( foo )
        expect( on.function_is_spent ).to eql false
        expect( on.value ).to eql [ [ :foo ], nil, nil ]
      end

      it "will stop at first non-parsable" do
        argv = [ '1', 'foo', '2', 'biz', 'bar' ]
        on = X_f_sp_Digits[ argv ]
        expect( on.function_is_spent ).to eql false
        expect( argv ).to eql [ 'biz', 'bar' ]
        expect( on.value ).to eql [ [ :foo ], nil, [ 1, 2 ] ]
      end
    end
  end
end
