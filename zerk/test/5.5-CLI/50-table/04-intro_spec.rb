require_relative '../../../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI support - table - actor" do

    TS_[ self ]
    use :memoizer_methods

    context "it is a pesudo-proc .." do

      before :all do
        X_cs_t_a_fs_s_m_Table = Home_::CLI_Support::Table::Actor
      end

      it "call it with nothing ane it renders nothing" do
        X_cs_t_a_fs_s_m_Table[].should eql nil
      end

      it "that is, an array of atoms won't fly either" do
        _rx = ::Regexp.new "\\Aundefined\\ method\\ `each_wi"

        begin
          X_cs_t_a_fs_s_m_Table[ [ :a, :b ] ]
        rescue NoMethodError => e
        end

        e.message.should match _rx
      end

      it "here is the smallest table you can render, which is boring" do
        ( X_cs_t_a_fs_s_m_Table[ [] ] ).should eql ''
      end

      it "default styling (\"| \", \" |\") is evident in this minimal non-empty table" do
        ( X_cs_t_a_fs_s_m_Table[ [ [ 'a' ] ] ] ).should eql "| a |\n"
      end

      it "minimal normative example" do

        _act = X_cs_t_a_fs_s_m_Table[ [ [ 'Food', 'Drink' ], [ 'donuts', 'coffee' ] ] ]

        _exp = <<-HERE.gsub %r<^ +>, EMPTY_S_
           | Food   | Drink  |
           | donuts | coffee |
        HERE

        _act.should eql _exp
      end
    end

    it "specify custom headers, separators, and output functions" do

      a = []

      _x = Home_::CLI_Support::Table::Actor.call(

        :field, 'Food', :field, 'Drink',

        :left, '(', :sep, ',', :right, ')',

        :read_rows_from, [[ 'nut', 'pomegranate' ]],

        :write_lines_to, a,
      )

      _x.object_id.should eql a.object_id

      ( a * 'X' ).should eql "(Food,Drink      )X(nut ,pomegranate)"
    end

    it "add field modifiers between the `field` keyword and its label (left/right)" do

      _str = Home_::CLI_Support::Table::Actor.call(
        :field, :right, :label, "Subproduct",
        :field, :left, :label, "num test files",
        :read_rows_from, [ [ 'face', 100 ], [ 'headless', 99 ] ],
      )

      _exp = <<-HERE.unindent
        | Subproduct | num test files |
        |       face | 100            |
        |   headless | 99             |
      HERE

      _str.should eql _exp
    end

    context "but the real fun begins with currying" do

      before :all do
        X_cs_t_a_fs_s_m_P = Home_::CLI_Support::Table::Actor.curry :left, '<', :sep, ',', :right, ">"
      end

      it "and then use it in another place" do
        ( X_cs_t_a_fs_s_m_P[ [ %w(a b), %w(c d) ] ] ).should eql "<a,b>\n<c,d>\n"
      end

      it "you can optionally modify the properties for your call" do
        ( X_cs_t_a_fs_s_m_P[ :sep, ';', :read_rows_from, [%w(a b), %w(c d)] ] ).should eql "<a;b>\n<c;d>\n"
      end

      shared_subject :q do
        X_cs_t_a_fs_s_m_P.curry :sep, '_'
      end

      it "call the curry with one dootiy-hah" do
        q.call(
          :read_rows_from, [ %w'a b' ],
        ).should eql "<a_b>\n"
      end

      it "call the curry with the other dootily-hah" do
        q.call(
          :read_rows_from, [ %w'c d' ],
          :left, 'HUZZAH ',
        ).should eql "HUZZAH c_d>\n"
      end
    end
  end
end
