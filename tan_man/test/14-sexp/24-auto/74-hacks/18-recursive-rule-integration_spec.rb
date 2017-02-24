require_relative '../../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] sexp - auto - hacks - recursive rule integration", g: true, wip: true do

    TS_[ self ]
    use :sexp_auto_hacks

    context "against a `stmt_list`" do

      use_statement_list_instance_methods__

      context "against zero items, prototype with separator semantics" do

        against_string "\n#one comment\n"
        add_separating_prototype_to_stmt_list

        it "any append - result has separator semantics, goes after comment" do
          insrt 'alpha'
          @graph_sexp.unparse.should eql "digraph{\n#one comment\nalpha}"
          @stmt_list_s.should eql "alpha"
        end
      end

      context "against one item, prototype with separator semantics" do

        against_string 'marmalade;   '  # three spaces
        add_separating_prototype_to_stmt_list

        it "position 1 - uses the prototype for the separator" do
          insrt 'barmalade'
          @stmt_list_s.should eql "barmalade\nmarmalade;   "
        end

        it "position 2 - adds no space or addtnl sep (i.e does not use proto)" do
          insrt 'parmalade'
          @stmt_list_s.should eql 'marmalade;   parmalade'
        end
      end

      context "againt two items, no prototype - existing has delimiter semantics" do

        against_string "boo\n\nloo\n\n\n"

        it "position 1 - use proximity styling (use first node)" do
          insrt 'aoo'
          @stmt_list_s.should eql "aoo\n\nboo\n\nloo\n\n\n"
        end

        it "position 2 - use proximity styling (first node trumps second)" do
          insrt 'coo'
          @stmt_list_s.should eql "boo\n\ncoo\n\nloo\n\n\n"
        end

        it "position 3 - per proximity styling use styling of item 2" do
          insrt 'moo'
          @stmt_list_s.should eql "boo\n\nloo\n\n\nmoo\n\n\n"
        end
      end

      context "against two items, no prototype - existing has separator semantics" do

        against_string "abo\n\nbeebo"

        it "position 3 - delimiter from item 1 is used, styled like item 2" do
          insrt 'ceebo'
          @stmt_list_s.should eql "abo\n\nbeebo\n\nceebo"
        end
      end
    end

    context "against an `attr_list`" do

      use_attr_list_instance_methods__

      context "against zero items" do

        against_string EMPTY_S_

        it "any append (hacked) - surface expressions use separator semantics (i.e nothing)" do
          insrt 'nazir=zenith'
          @a_list_s.should eql 'nazir=zenith'
        end
      end

      context "against one item (with prototype)" do

        against_string 'koo=k'

        it "position 1 - uses (necessarily) prototype for styling" do
          insrt 'boo=b'
          @a_list_s.should eql 'boo=b, koo=k'
        end

        it "position 2 - uses (necessarily) prototype for styling" do
          insrt 'moo=m'
          @a_list_s.should eql 'koo=k, moo=m'
        end
      end

      context "against two items (with prototype)" do

        against_string 'biffo=x,  kiffo=y'

        it "position 1 - use proximity styling" do
          insrt 'aiffo=a'
          @a_list_s.should eql 'aiffo=a,  biffo=x,  kiffo=y'
        end

        it "position 2 - use proximity styling" do
          insrt 'giffo=g'
          @a_list_s.should eql 'biffo=x,  giffo=g,  kiffo=y'
        end

        it "position 3 - use proximity styling" do
          insrt 'liffo=l'
          @a_list_s.should eql 'biffo=x,  kiffo=y,  liffo=l'
        end
      end
    end
  end
end
