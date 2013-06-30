require_relative 'test-support'

describe "Skylab::MetaHell::FUN" do

  MetaHell = ::Skylab::MetaHell

  MetaHell::DSL_DSL.enhance self do
    atom :h
    list :op_a
  end

  def parse *args
    f_a = op_a.map { |i| h.fetch i }
    MetaHell::FUN.parse_series[ args, * f_a ]
  end

  context "`parse_series`" do

    m_f = %i( m f )

    h( age: -> x { ::Numeric === x },
       sex: -> x { m_f.include? x },
       loc: -> _ { }  # left here to prove that op_a != h.keys
    )

    context "against one" do

      op_a :sex

      it "zero" do
        parse.should eql( [ nil ] )
      end

      it "one valid" do
        parse( :m ).should eql( [ :m ] )
      end

      it "one invalid" do
        -> do
          parse 'blah'
        end.should raise_error( ::ArgumentError, /unrecog.+index 0.+blah/i )
      end

      it "one valid then one invalid" do
        -> do
          parse :m, :f
        end.should raise_error( ::ArgumentError, /unrecog.+index 1.+:f/i )
      end
    end

    context "against two" do

      op_a :age, :sex

      it "zero" do
        parse.should eql( [ nil, nil ] )
      end

      it "one (a)" do
        parse( 12 ).should eql( [ 12, nil ] )
      end

      it "one (b)" do
        parse( :m ).should eql( [ nil, :m ] )
      end

      it "two" do
        parse( 12, :m ).should eql( [ 12, :m ] )
      end

      it "wrong order" do
        -> do
          parse :m, 12
        end.should raise_error( ::ArgumentError, /unrec.+index 1.+\b12\b/i )
      end
    end
  end
end
