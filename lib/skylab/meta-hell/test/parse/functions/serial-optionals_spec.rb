require_relative 'serial-optionals/test-support'

module Skylab::MetaHell::TestSupport::Parse::Serial_Optionals

describe "[mh] serial optionals" do

  extend TS_

  context "my first nonterminal (integration)" do

    define_method :subject, ( Callback_.memoize do

      Subject_[].function_( :serial_optionals ).new_with(
        :functions,
          :keyword,
            'randomize', :minimum_number_of_characters, 3,
          :non_negative_integer )
    end )


    it "builds" do
      subject or fail
    end

    it "built thing is a stream parser (parse a full normal input)" do
      against( 'rando', '2' ).value_x.should eql [ :randomize, 2 ]
    end
  end

  it "minimal high level" do

    is_A, is_B = Subject_[].serial_optionals [ :B ],
      -> x { :A == x and :foo },
      -> x { :B == x and :bar }

    is_A.should be_nil
    is_B.should eql :B

  end

  context "periphery" do

    LIB_.DSL_DSL.enhance self do
      atom :formal_symbol_h
      list :formal_symbols
    end

    _SEX_I_A__ = %i( m f )

    formal_symbol_h(
       age:
         -> x { ::Numeric === x },
       sex:
         -> x { _SEX_I_A__.include? x },
       loc:
         MetaHell_::MONADIC_EMPTINESS_ )

    context "a grammar with one formal symbol" do

      formal_symbols :sex

      it "against zero input tokens - is OK" do
        parse.should eql [ nil ]
      end

      it "against one valid input token" do
        parse( :m ).should eql [ :m ]
      end

      it "against one invalid input token - no" do
        _rx = /\bunrecognized argument 'blah'/
        -> do
          parse 'blah'
        end.should raise_error( ::ArgumentError, _rx )
      end

      it "if there is more than one (albeit valid) input tokens - no" do
        -> do
          parse :m, :f
        end.should raise_error( ::ArgumentError, /unrecognized argument 'f'/ )
      end
    end

    context "a grammar with two formal symbols" do

      formal_symbols :age, :sex

      it "against zero input tokens - is OK" do
        parse.should eql [ nil, nil ]
      end

      it "against a valid input token (that is a production of the 1st formal symbol)" do
        parse( 12 ).should eql [ 12, nil ]
      end

      it "against a valid input token (that is a production of the 2nd formal symbol)" do
        parse( :m ).should eql [ nil, :m ]
      end

      it "against two valid input tokens (of the first then second formal symbols)" do
        parse( 12, :m ).should eql [ 12, :m ]
      end

      it "if the \"valid\" input tokens are in the wrong order - no" do
        -> do
          parse :m, 12
        end.should raise_error( ::ArgumentError, /unrecognized argument '12'/ )
      end
    end
  end

  def parse *args

    h = formal_symbol_h

    Subject_[].serial_optionals args, * (
      formal_symbols.map do | sym |
        h.fetch sym
      end )

  end

end
end
