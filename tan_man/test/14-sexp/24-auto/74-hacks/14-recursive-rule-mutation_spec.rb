require_relative '../../../test-support'

describe "[tm] sexp - auto - hacks - recursive rule mutation", g: true do

  Skylab::TanMan::TestSupport[ self ]
  use :sexp_auto_hacks

  using_grammar '70-75-minimal-recursive-list' do

    using_input_string 'fip ;  ', 'against one item' do

      context 'add to' do

        it 'position 1 - fails because no prototype' do
          begin
            result.insert_item_before_item_string_ 'fap', 'fip'
          rescue _same_ex_class => e
          end
          e || fail
        end


        it 'position 2 (append) - fails because no prototype' do
          begin
            result.insert_item_before_item_string_ 'fap', 'fip'
          rescue _same_ex_class => e
          end
          e || fail
        end

        def _same_ex_class
          subject::PrototypeRequired
        end
      end

      context 'remove', remove: true do

        o = Skylab::TanMan::TestSupport

        it 'the only (and hence last) item, yielding a stub' do
          removed_x = result.remove_item_via_string_ 'fip'
          node_s_a.should eql o::EMPTY_A_
          removed_x.should eql 'fip'
          result.unparse.should eql o::EMPTY_S_
        end
      end
    end

    using_input_string "feep ; forp ; \n", 'against two items' do

      context 'add to' do

        it 'position 1 - use first as prototype' do
          inserted = result.insert_item_before_item_string_ 'faap', 'feep'
          node_s_a.should eql [ 'faap', 'feep', 'forp' ]
          @result.unparse.should eql "faap ; feep ; forp ; \n"
          inserted.object_id.should eql @result.object_id  # yikes
        end

        it 'position 2 - use ??? as prototype' do
          inserted = result.insert_item_before_item_string_ 'faap', 'forp'
          node_s_a.should eql ['feep', 'faap', 'forp' ]
          @result.unparse.should eql "feep ; faap ; forp ; \n"
          inserted.content.should eql 'faap'
        end

        it "position 3 - appending to [A B] node C; use B as proto, B gets A's separator" do
          inserted = result.append_item_via_string_ 'fuup;'
          node_s_a.should eql [ 'feep', 'forp', 'fuup' ]
          @result.unparse.should eql "feep ; forp ; fuup ; \n"
          inserted.unparse.should eql "fuup ; \n"
        end
      end

      context 'remove', remove: true do

        it 'item 1 - result is removed node, both unparse sanely' do
          removed_x = result.remove_item_via_string_ 'feep'
          node_s_a.should eql ['forp']
          result.unparse.should eql "forp ; \n"
          removed_x.should eql 'feep'
        end

        it 'item 2 - result is removed node, both unparse sanely' do
          removed_x = result.remove_item_via_string_ 'forp'
          node_s_a.should eql [ 'feep' ]
          result.unparse.should eql 'feep ; '
          removed_x.should eql 'forp'
        end
      end
    end

    using_input_string "fap;fep ; fip ;\n ", 'against three items' do

      context 'add to' do

        it 'position 1 - uses item 1 as prototype' do
          result.insert_item_before_item_string_ 'faap', 'fap'
          @result.unparse.should eql "faap;fap;fep ; fip ;\n "
        end

        it 'position 2 - uses item 1 as prototype' do
          result.insert_item_before_item_string_ 'faap', 'fep'
          @result.unparse.should eql "fap;faap;fep ; fip ;\n "
        end

        it 'position 3 - use item 2 as prototype' do
          result.insert_item_before_item_string_ 'faap', 'fip'
          @result.unparse.should eql "fap;fep ; faap ; fip ;\n "
        end

        it 'position 4 (append) - mutate the final two appropriately' do
          result.append_item_via_string_ 'faap  ;  '
          @result.unparse.should eql "fap;fep ; fip ; faap ;\n "
        end
      end

      context 'remove', remove: true do

        it 'item 1 - result is removed node, both unparse sanely' do
          removed_x = result.remove_item_via_string_ 'fap'
          node_s_a.should eql ['fep', 'fip']
          result.unparse.should eql "fep ; fip ;\n "
          removed_x.should eql 'fap'
        end

        it 'item 2 - result is removed node, both unparse sanely' do
          removed_x = result.remove_item_via_string_ 'fep'
          node_s_a.should eql [ 'fap', 'fip' ]
          result.unparse.should eql "fap;fip ;\n "
          removed_x.should eql 'fep'
        end
      end
    end
  end
end
