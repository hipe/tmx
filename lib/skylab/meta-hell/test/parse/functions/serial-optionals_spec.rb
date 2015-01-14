require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse::Series

describe "[mh] parse series (periphery)" do

  LIB_.DSL_DSL.enhance self do
    atom :formal_symbol_h
    list :formal_symbols
  end

  context "`parse_series`" do

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
        -> do
          parse 'blah'
        end.should raise_error( ::ArgumentError, /unrecog.+index 0.+blah/i )
      end

      it "if there is more than one (albeit valid) input tokens - no" do
        -> do
          parse :m, :f
        end.should raise_error( ::ArgumentError, /unrecog.+index 1.+:f/i )
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
        end.should raise_error( ::ArgumentError, /unrec.+index 1.+\b12\b/i )
      end
    end
  end

  def parse *args

    h = formal_symbol_h

    Subject_[].series args, * (
      formal_symbols.map do | sym |
        h.fetch sym
      end )

  end

end
end
