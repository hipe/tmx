require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse::Spending_Pool

  describe "[mh] Parse::Via_Set__" do

    context "with one such parser build from an empty set of parsers" do

      before :all do
        None = Subject_[].new_with( :functions ).to_output_node_and_mutate_array_proc
      end
      it "a parser with no nodes in it will always report 'no parse' and 'spent'" do
        None[ MetaHell_::EMPTY_A_ ].should be_nil
      end
      it "even if the input is rando calrissian" do
        None[ :hi_mom ].should be_nil
      end
    end
    context "with parser with one node that reports it always matches & always spends" do

      before :all do

        One = Subject_[].new_with(
          :functions,
            :proc, -> in_st do
              Parse_lib_[]::Output_Node_.new nil
            end ).to_output_node_and_mutate_array_proc

      end
      it "is always this same output node" do
        on = One[ :whatever ]
        on.function_is_spent.should eql true
      end
    end
    context "with a parser with one node that reports it never matches & always spends" do

      before :all do
        Spendless = Subject_[].new_with(
          :functions,
            :proc, -> in_st do
              nil
            end ).to_output_node_and_mutate_array_proc
      end
      it "never parses" do
        Spendless[ :whatever ].should be_nil
      end
    end
    context "of 2 keywords, parse them at most once each. parse any and all digits" do

      before :all do

        _NNI = Parent_::Subject_[]::Functions_::Non_Negative_Integer

        Digits = Subject_[].new_with(
          :functions,
            :keyword, "foo",
            :keyword, "bar",
            :proc, -> in_st do
              on = _NNI.output_node_via_input_stream in_st
              if on
                on.new_with :function_is_not_spent
              end
            end ).to_output_node_and_mutate_array_proc
      end
      it "does nothing with nothing" do
        Digits[ MetaHell_::EMPTY_A_ ].should eql nil
      end
      it "parses one digit" do
        argv = [ '1' ]
        on = Digits[ argv ]
        argv.length.should eql 0
        on.function_is_spent.should eql false
        kw, k2, digits = on.value_x
        ( kw || k2 ).should be_nil
        digits.should eql [ 1 ]
      end
      it "parses two digits" do
        argv = %w( 2 3 )
        on = Digits[ argv ]
        on.function_is_spent.should eql false
        on.value_x.should eql [ nil, nil, [ 2, 3 ] ]
      end
      it "parses one keyword" do
        argv = [ 'bar' ]
        on = Digits[ argv ]
        on.function_is_spent.should eql false
        on.value_x.should eql [ nil, [:bar], nil ]
      end
      it "parses two keywords (in reverse grammar order)" do
        argv = %w( bar foo )
        on = Digits[ argv ]
        argv.length.should eql 0
        on.function_is_spent.should eql false
        on.value_x.should eql [ [:foo], [:bar], nil ]
      end
      it "will not parse multiple of same keyword" do
        argv = %w( foo foo )
        on = Digits[ argv ]
        argv.should eql %w( foo )
        on.function_is_spent.should eql false
        on.value_x.should eql [ [ :foo ], nil, nil ]
      end
      it "will stop at first non-parsable" do
        argv = [ '1', 'foo', '2', 'biz', 'bar' ]
        on = Digits[ argv ]
        on.function_is_spent.should eql false
        argv.should eql [ 'biz', 'bar' ]
        on.value_x.should eql [ [ :foo ], nil, [ 1, 2 ] ]
      end
    end
  end
end
