require_relative '../../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - serial optionals - core" do

    TS_[ self ]
    use :memoizer_methods

    it "there is a highlevel shorthand inline convenience macro" do

      _argv = [ '30', 'brisbane' ]

      age, sex, loc =  Home_.parse_serial_optionals _argv,
        -> a { /\A\d+\z/ =~ a },
        -> s { /\A[mf]\z/i =~ s },
        -> l { /./ =~ l }

      age.should eql '30'
      sex.should eql nil
      loc.should eql 'brisbane'
    end

    context "currying can make your code more readable and may improve performance" do

      shared_subject :p do
        p = Home_.function( :serial_optionals ).new_with(
          :matcher_functions,
            -> age do
              /\A\d+\z/ =~ age
            end,
            -> sex do
              /\A(?:m(?:ale)?|f(?:emale)?|o(?:ther)?)\z/i =~ sex
            end,
            -> location do
              /\A[A-Z]/ =~ location   # must start with capital
            end ).to_parse_array_fully_proc

        p
      end

      it "full normal case (works to match each of the three terms)." do
        ( p[ [ '30', 'male', "Mom's basement" ] ] ).should eql [ '30', 'male', "Mom's basement" ]
      end

      it "one valid input token will match any first matching formal symbol found" do
        ( p[ [ '30' ] ] ).should eql [ '30', nil, nil ]
      end

      it "successful result is always array as long as number of formal symbols" do
        ( p[ [ "Mom's basement" ] ] ).should eql [ nil, nil, "Mom's basement" ]
      end

      it "ergo an earlier matching formal symbol will always win over a later one" do
        ( p[ [ 'M' ] ] ).should eql [ nil, 'M', nil ]
      end

      it "because we have that 'fully' suffix, we raise argument errors" do

        argv = [ '30', 'm', "Mom's", "Mom's again" ]
        _rx = ::Regexp.new "\\Aunrecognized\\ argument\\ \"Mom's"

        begin
          p[ argv ]
        rescue ArgumentError => e
        end

        e.message.should match _rx
      end
    end

    context "you can provide arbitrary procs to implement your parse functions" do

      shared_subject :p do

        feet_rx = /\A\d+\z/
        inch_rx = /\A\d+(?:\.\d+)?\z/

        p = Home_.function( :serial_optionals ).new_with(
          :functions,
          :proc, -> st do
            if feet_rx =~ st.current_token_object.value_x
              tok = st.current_token_object
              st.advance_one
              Home_::OutputNode.for tok.value_x.to_i
            end
          end,
          :proc, -> st do
            if inch_rx =~ st.current_token_object.value_x
              tok = st.current_token_object
              st.advance_one
              Home_::OutputNode.for tok.value_x.to_f
            end
          end ).to_parse_array_fully_proc

        p
      end

      it "if it's an integer, it matches the first pattern" do
        ( p[ [ "8"   ] ] ).should eql [ 8,  nil  ]
      end

      it "but if it's a float, it matches the second pattern" do
        ( p[ [ "8.1" ] ] ).should eql [ nil, 8.1 ]
      end

      it "still falls into the float \"slot\"" do
        ( p[ [ "8", "9" ] ] ).should eql [ 8, 9.0 ]
      end

      it "but the converse is not true; i.e you can't have two floats" do

        _rx = ::Regexp.new "\\Aunrecognized\\ argument"

        begin
          p[ [ "8.1", "8.2" ] ]
        rescue ArgumentError => e
        end

        e.message.should match _rx
      end
    end
  end
end
