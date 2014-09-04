require_relative 'test-support'

module ::Skylab::TanMan::TestSupport::Sexp::Auto::Recursive_Rule

  describe "[tm] Sexp ::Auto hacks recursive rule - THE GAUNTLET", wip: true do

    extend TS_

    context "with stmt_list" do
      include Stmt_List_I_M
      context "on zero" do
        it "1.1 - one on zero - no separators, goes after comment" do
          go 'alpha'
          graph_sexp.unparse.should eql( "digraph{\n#one comment\nalpha}" )
          expect 'alpha'
        end
        with "\n#one comment\n"
        give_stmt_list_a_prototype
      end
      context "on one" do
        it "2.1 - one after one - adds no space or addtnl sep" do
          go 'parmalade'
          expect 'marmalade;   parmalade'
        end
        it "2.2 - one before one - uses prototype spacing" do
          go 'barmalade'
          expect "barmalade\nmarmalade;   "
        end
        with 'marmalade;   ' # three spaces
        give_stmt_list_a_prototype
      end
      context "on two" do
        it "3.1 - one after two - last post ws is used" do
          go 'moo'
          expect "boo\n\nloo\n\n\nmoo\n\n\n"
        end
        it "3.2 - one between two - lpwis" do
          go 'coo'
          expect "boo\n\ncoo\n\n\nloo\n\n\n"
        end
        it "3.3 - one before two - first post ws is used" do
          go 'aoo'
          expect "aoo\n\nboo\n\nloo\n\n\n"
        end
        with "boo\n\nloo\n\n\n"
      end
    end
    context "with attr_list" do
      include Attr_List_I_M
      context "on zero" do
        it "1.1 - one on zero (hacked) - no separators, good!" do
          go 'nazir=zenith'
          expect 'nazir=zenith'
        end
        with ''
      end
      context "on one" do
        it "2.1 - one after one - uses comma and space" do
          go 'moo=m'
          expect 'koo=k, moo=m'
        end
        it "2.2 - one before one - uses comma and space" do
          go 'boo=b'
          expect 'boo=b, koo=k'
        end
        with 'koo=k'
      end
      context "on two" do
        it "3.1 - one after two - uses comma and *one* space per proto" do
          go 'liffo=l'
          expect 'biffo=x,  kiffo=y, liffo=l'
        end
        it "3.2 - one between two - uses command and one leading space" do
          go 'giffo=g'
          expect 'biffo=x, giffo=g,  kiffo=y'
        end
        it "3.3 - one before two - commas OK" do
          go 'aiffo=a'
          expect 'aiffo=a, biffo=x,  kiffo=y'
        end
        with 'biffo=x,  kiffo=y'
      end
    end
  end
end
