require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Table

  describe "[fa] CLI::Table" do

    context "is a pesudo-proc .." do

      before :all do
        Table = Face_::CLI::Table
      end
      it "call it with nothing and it renders nothing" do
        Table[].should eql nil
      end
      it "call it with one thing, must respond to each (in two dimensions)" do
        -> do
          Table[ :a ]
        end.should raise_error( NoMethodError,
                     ::Regexp.new( "\\Aundefined\\ method\\ `each'\\ for\\ :a" ) )
      end
      it "that is, an array of atoms won't fly either" do
        -> do
          Table[ [ :a, :b ] ]
        end.should raise_error( NoMethodError,
                     ::Regexp.new( "\\Aundefined\\ method\\ `each_wi" ) )
      end
      it "here is the smallest table you can render, which is boring" do
        Table[ [] ].should eql ''
      end
      it "default styling (\"| \", \" |\") is evident in this minimal non-empty table" do
        Table[ [ [ 'a' ] ] ].should eql "| a |\n"
      end
      it "minimal normative example" do
        act = Table[ [ [ 'Food', 'Drink' ], [ 'donuts', 'coffee' ] ] ]
        exp = <<-HERE.gsub %r<^ +>, ''
          | Food   | Drink  |
          | donuts | coffee |
        HERE
        act.should eql exp
      end
    end
    it "specify custom headers, separators, and output functions" do
      a = []
      x = Face_::CLI::Table[ :field, 'Food', :field, 'Drink',
        :left, '(', :sep, ',', :right, ')',
        :read_rows_from, [[ 'nut', 'pomegranate' ]],
        :write_lines_to, a.method( :<< ) ]

      x.should eql nil
      ( a * 'X' ).should eql "(Food,Drink      )X(nut ,pomegranate)"
    end
    it "add field modifiers between the `field` keyword and its label (left/right)" do
      str = Face_::CLI::Table[
        :field, :right, :label, "Subproduct",
        :field, :left, :label, "num test files",
        :read_rows_from, [ [ 'face', 100 ], [ 'headless', 99 ] ] ]

      exp = <<-HERE.unindent
        | Subproduct | num test files |
        |       face | 100            |
        |   headless | 99             |
      HERE
      str.should eql exp
    end
    context "you can curry properties and behavior for table in one place .." do

      before :all do
        P = Face_::CLI::Table.curry :left, '<', :sep, ',', :right, '>'
      end
      it "and then use it in another place" do
        P[ [ %w(a b), %w(c d) ] ].should eql "<a,b>\n<c,d>\n"
      end
      it "you can optionally modify the properties for your call" do
        P[ :sep, ';', :read_rows_from, [%w(a b), %w(c d)] ].should eql "<a;b>\n<c;d>\n"
      end
      it "you can even curry the curried \"function\", curry the data, and so on -" do
        q = P.curry( :read_rows_from, [ %w( a b ) ], :sep, 'X' )
        q[ :sep, '_' ].should eql "<a_b>\n"
        q[].should eql "<aXb>\n"
      end
    end
  end
end
