require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Table

  describe "Skylab::Face::CLI::Table" do
    context "a table" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          Table = Face::CLI::Table
        end
      end
      it "with nothing renders nothing" do
        Sandbox_1.with self
        module Sandbox_1
          Table[].should eql( nil )
        end
      end
      it "with one thing, must respond to each (in two dimensions)" do
        Sandbox_1.with self
        module Sandbox_1
          -> do
            Table[ :a ]
          end.should raise_error( NoMethodError,
                       ::Regexp.new( "\\Aundefined\\ method\\ `each'\\ for\\ :a" ) )
        end
      end
      it "that is, an array of atoms won't fly either" do
        Sandbox_1.with self
        module Sandbox_1
          -> do
            Table[ [ :a, :b ] ]
          end.should raise_error( NoMethodError,
                       ::Regexp.new( "\\Aundefined\\ method\\ `each_wi" ) )
        end
      end
      it "but here is the smallest table you can render, which is boring" do
        Sandbox_1.with self
        module Sandbox_1
          Table[ [] ].should eql( '' )
        end
      end
      it "here's a minimal non-empty table (note you get default styling)" do
        Sandbox_1.with self
        module Sandbox_1
          Table[ [ [ 'a' ] ] ].should eql( "|  a |\n" )
        end
      end
      it "for a minimal normative example" do
        Sandbox_1.with self
        module Sandbox_1
          act = Table[ [ [ 'Food', 'Drink' ], [ 'donuts', 'coffee' ] ] ]
          exp = <<-HERE.gsub %r<^ +>, ''
            |    Food |   Drink |
            |  donuts |  coffee |
          HERE
          act.should eql( exp )
        end
      end
    end
    context "but wait there's more-" do
      Sandbox_2 = Sandboxer.spawn
      it "you can specify custom headers, separators, and output functions" do
        Sandbox_2.with self
        module Sandbox_2
          Table = Face::CLI::Table
          a = []
          r = Table[ :field, 'Food', :field, 'Drink',
                     :left, '(', :sep, ',', :right, ')',
                     :read_rows_from, [[ 'nut', 'pomegranate' ]],
                     :write_lines_to, a.method( :<< )
                     ]

          r.should eql( nil )
          ( a * 'X' ).should eql( "(Food,      Drink)X( nut,pomegranate)" )
        end
      end
    end
    context "this syntax is \"contoured\" - fields themselves eat keywords" do
      Sandbox_3 = Sandboxer.spawn
      it "like so : you can align `left` or `right` (and watch for etc)" do
        Sandbox_3.with self
        module Sandbox_3
          str = Face::CLI::Table[
            :field, :right, :label, "Subproduct",
            :field, :left, :label, "num test files",
            :read_rows_from, [ [ 'face', '100' ], [ 'headless', '99' ] ] ]

          exp = <<-HERE.unindent
            |  Subproduct |  num test files |
            |        face |  100            |
            |    headless |  99             |
          HERE
          str.should eql( exp )
        end
      end
    end
    context "but the real fun begins with currying - curry a table in one place" do
      Sandbox_4 = Sandboxer.spawn
      before :all do
        Sandbox_4.with self
        module Sandbox_4
          P = Face::CLI::Table.curry :left, '<', :sep, ',', :right, '>'
        end
      end
      it "and (perhaps modify it) and use it in another (CASCADING stylesheet like!)" do
        Sandbox_4.with self
        module Sandbox_4
          P[ :sep, ';', :read_rows_from, [%w(a b), %w(c d)] ].should eql( "<a;b>\n<c;d>\n" )
          P[ [ %w(a b), %w(c d) ] ].should eql( "<a,b>\n<c,d>\n" )
        end
      end
      it "you can even curry the curried \"function\", curry the data, and so on -" do
        Sandbox_4.with self
        module Sandbox_4
          Q = P.curry( :read_rows_from, [ %w( a b ) ], :sep, 'X' )
          Q[ :sep, '_' ].should eql( "<a_b>\n" )
          Q[].should eql( "<aXb>\n" )
        end
      end
    end
  end
end
