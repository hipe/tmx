require_relative '../test-support'

module Skylab::Parse::TestSupport

  # <-
describe "[pa] fuctions - serial optionals" do

  extend TS_

  context "my first nonterminal (integration)" do

    memoize_subject_parse_function_ do

      Parse_.function( :serial_optionals ).new_with(
        :functions,
          :keyword,
            'randomize', :minimum_number_of_characters, 3,
          :non_negative_integer )
    end

    it "builds" do
      subject_parse_function_ or fail
    end

    it "built thing is a stream parser (_parse a full normal input)" do
      against_( 'rando', '2' ).value_x.should eql [ :randomize, 2 ]
    end
  end

  it "minimal high level" do

    is_A, is_B = Parse_.parse_serial_optionals [ :B ],
      -> x { :A == x and :foo },
      -> x { :B == x and :bar }

    is_A.should be_nil
    is_B.should eql :B

  end

  context "periphery" do

    Parse_::DSL_DSL.enhance self do

      atom :_formal_symbol_h
      list :_formal_symbols
    end

    _SEX_I_A__ = %i( m f )

    _formal_symbol_h(
       age:
         -> x { ::Numeric === x },
       sex:
         -> x { _SEX_I_A__.include? x },
       loc:
         -> x { NIL_ } )  # `MONADIC_EMPTINESS_`

    context "a grammar with one formal symbol" do

      _formal_symbols :sex

      it "against zero input tokens - is OK" do
        _parse.should eql [ nil ]
      end

      it "against one valid input token" do
        _parse( :m ).should eql [ :m ]
      end

      it "against one invalid input token - no" do
        _rx = /\bunrecognized argument 'blah'/
        -> do
          _parse 'blah'
        end.should raise_error( ::ArgumentError, _rx )
      end

      it "if there is more than one (albeit valid) input tokens - no" do
        -> do
          _parse :m, :f
        end.should raise_error( ::ArgumentError, /unrecognized argument 'f'/ )
      end
    end

    context "a grammar with two formal symbols" do

      _formal_symbols :age, :sex

      it "against zero input tokens - is OK" do
        _parse.should eql [ nil, nil ]
      end

      it "against a valid input token (that is a production of the 1st formal symbol)" do
        _parse( 12 ).should eql [ 12, nil ]
      end

      it "against a valid input token (that is a production of the 2nd formal symbol)" do
        _parse( :m ).should eql [ nil, :m ]
      end

      it "against two valid input tokens (of the first then second formal symbols)" do
        _parse( 12, :m ).should eql [ 12, :m ]
      end

      it "if the \"valid\" input tokens are in the wrong order - no" do
        -> do
          _parse :m, 12
        end.should raise_error( ::ArgumentError, /unrecognized argument '12'/ )
      end
    end
  end

  def _parse *args

    h = _formal_symbol_h

    Parse_.parse_serial_optionals args, * (
      _formal_symbols.map do | sym |
        h.fetch sym
      end )

  end
end
# ->
end
