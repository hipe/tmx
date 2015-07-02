require_relative '../../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - exp-fr - table - actor" do

    context "is a pesudo-proc .." do

      it "call it with nothing and it renders nothing" do

        _subject_callable[].should be_nil
      end

      it "here is the smallest table you can render, which is boring" do

        _subject_callable[ [] ].should eql EMPTY_S_
      end

      it "default styling (\"| \", \" |\") is evident in this minimal non-empty table" do

        _subject_callable[ [ [ 'a' ] ] ].should eql "| a |\n"
      end

      it "minimal normative example" do

        _act = _subject_callable[ [ [ 'Food', 'Drink' ], [ 'donuts', 'coffee' ] ] ]

        _exp = <<-HERE.gsub %r<^ +>, EMPTY_S_
          | Food   | Drink  |
          | donuts | coffee |
        HERE

        _act.should eql _exp
      end
    end

    it "specify custom headers, separators, and output functions" do

      a = []

      _x = _subject_callable.call(

        :field, 'Food', :field, 'Drink',

        :left, '(', :sep, ',', :right, ')',

        :read_rows_from, [[ 'nut', 'pomegranate' ]],

        :write_lines_to, a
      )

      _x.object_id.should eql a.object_id

      ( a * 'X' ).should eql "(Food,Drink      )X(nut ,pomegranate)"
    end

    it "add field modifiers between the `field` keyword and its label (left/right)" do

      _str = _subject_callable[
        :field, :right, :label, "Subproduct",
        :field, :left, :label, "num test files",
        :read_rows_from, [ [ 'face', 100 ], [ 'headless', 99 ] ] ]

      _exp = <<-HERE.unindent
        | Subproduct | num test files |
        |       face | 100            |
        |   headless | 99             |
      HERE

      _str.should eql _exp
    end

    _Subject_callable = -> do
      Home_::CLI::Expression_Frames::Table::Actor
    end

    context "you can curry properties and behavior for table in one place .." do

      _P = nil

      before :all do

        _P = _Subject_callable[].curry :left, '<', :sep, ',', :right, ">"
      end

      it "and then use it in another place" do

        _P[ [ %w(a b), %w(c d) ] ].should eql "<a,b>\n<c,d>\n"
      end

      it "you can optionally modify the properties for your call" do

        _P[ :sep, ';', :read_rows_from, [%w(a b), %w(c d)] ].should eql "<a;b>\n<c;d>\n"
      end

      it "you can even curry the curried \"function\", curry the data, and so on -" do

        q = _P.curry :sep, '_'

        q[
          :read_rows_from, [ %w( a b ) ],
        ].should eql "<a_b>\n"

        q[
          :read_rows_from, [ %w'c d' ],
          :left, 'HUZZAH ',
        ].should eql "HUZZAH c_d>\n"
      end
    end

    define_method :_subject_callable do
      _Subject_callable[]
    end
  end
end
