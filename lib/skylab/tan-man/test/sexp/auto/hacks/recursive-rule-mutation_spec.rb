require_relative 'test-support'

describe "[tm] sexp - auto - hacks - mutation", g: true do

  extend ::Skylab::TanMan::TestSupport::Sexp::Auto::Hacks

  using_grammar '70-75-minimal-recursive-list' do

    using_input_string 'fip ;  ', 'against one item' do

      context 'add to' do

        it 'position 1 - fails because no prototype' do
          -> do
            result._insert_item_before_item 'fap', 'fip'
          end.should raise_same_error
        end

        it 'position 2 (append) - fails because no prototype' do
          -> do
            result._insert_item_before_item 'fap', 'fip'
          end.should raise_same_error
        end

        def raise_same_error
          raise_error subject::Prototype_Required
        end
      end

      context 'remove', remove: true do

        it 'the only (and hence last) item, yielding a stub' do
          removed_x = result._remove_item 'fip'
          node_s_a.should eql ::Skylab::TanMan::EMPTY_A_
          removed_x.should eql 'fip'
          result.unparse.should eql ::Skylab::TanMan::EMPTY_S_
        end
      end
    end

    using_input_string "feep ; forp ; \n", 'against two items' do

      context 'add to' do

        it 'position 1 - use first as prototype' do
          inserted = result._insert_item_before_item 'faap;', 'feep'
          node_s_a.should eql [ 'faap', 'feep', 'forp' ]
          @result.unparse.should eql "faap ; feep ; forp ; \n"
          inserted.object_id.should eql @result.object_id  # yikes
        end

        it 'position 2 - use ??? as prototype' do
          inserted = result._insert_item_before_item 'faap;', 'forp'
          node_s_a.should eql ['feep', 'faap', 'forp' ]
          @result.unparse.should eql "feep ; faap ; forp ; \n"
          inserted.content.should eql 'faap'
        end

        it "position 3 - appending to [A B] node C; use B as proto, B gets A's separator" do
          inserted = result._append! 'fuup;'
          node_s_a.should eql [ 'feep', 'forp', 'fuup' ]
          @result.unparse.should eql "feep ; forp ; fuup ; \n"
          inserted.unparse.should eql "fuup ; \n"
        end
      end

      context 'remove', remove: true do

        it 'item 1 - result is removed node, both unparse sanely' do
          removed_x = result._remove_item 'feep'
          node_s_a.should eql ['forp']
          result.unparse.should eql "forp ; \n"
          removed_x.should eql 'feep'
        end

        it 'item 2 - result is removed node, both unparse sanely' do
          removed_x = result._remove_item 'forp'
          node_s_a.should eql [ 'feep' ]
          result.unparse.should eql 'feep ; '
          removed_x.should eql 'forp'
        end
      end
    end

    using_input_string "fap;fep ; fip ;\n ", 'against three items' do

      context 'add to' do

        it 'position 1 - uses item 1 as prototype' do
          result._insert_item_before_item 'faap  ;  ', 'fap'
          @result.unparse.should eql "faap;fap;fep ; fip ;\n "
        end

        it 'position 2 - uses item 1 as prototype' do
          result._insert_item_before_item 'faap  ;  ', 'fep'
          @result.unparse.should eql "fap;faap;fep ; fip ;\n "
        end

        it 'position 3 - use item 2 as prototype' do
          result._insert_item_before_item 'faap;', 'fip'
          @result.unparse.should eql "fap;fep ; faap ; fip ;\n "
        end

        it 'position 4 (append) - mutate the final two appropriately' do
          result._append! 'faap;'
          @result.unparse.should eql "fap;fep ; fip ; faap ;\n "
        end
      end

      context 'remove', remove: true do

        it 'item 1 - result is removed node, both unparse sanely' do
          removed_x = result._remove_item 'fap'
          node_s_a.should eql ['fep', 'fip']
          result.unparse.should eql "fep ; fip ;\n "
          removed_x.should eql 'fap'
        end

        it 'item 2 - result is removed node, both unparse sanely' do
          removed_x = result._remove_item 'fep'
          node_s_a.should eql [ 'fap', 'fip' ]
          result.unparse.should eql "fap;fip ;\n "
          removed_x.should eql 'fep'
        end
      end
    end
  end
end
