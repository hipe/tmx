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
          expect( node_s_a ).to eql o::EMPTY_A_
          expect( removed_x ).to eql 'fip'
          expect( result.unparse ).to eql o::EMPTY_S_
        end
      end
    end

    using_input_string "feep ; forp ; \n", 'against two items' do

      context 'add to' do

        it 'position 1 - use first as prototype' do
          inserted = result.insert_item_before_item_string_ 'faap', 'feep'
          expect( node_s_a ).to eql [ 'faap', 'feep', 'forp' ]
          expect( @result.unparse ).to eql "faap ; feep ; forp ; \n"
          expect( inserted.object_id ).to eql @result.object_id  # yikes
        end

        it 'position 2 - use ??? as prototype' do
          inserted = result.insert_item_before_item_string_ 'faap', 'forp'
          expect( node_s_a ).to eql ['feep', 'faap', 'forp' ]
          expect( @result.unparse ).to eql "feep ; faap ; forp ; \n"
          expect( inserted.content ).to eql 'faap'
        end

        it "position 3 - appending to [A B] node C; use B as proto, B gets A's separator" do
          inserted = result.append_item_via_string_ 'fuup;'
          expect( node_s_a ).to eql [ 'feep', 'forp', 'fuup' ]
          expect( @result.unparse ).to eql "feep ; forp ; fuup ; \n"
          expect( inserted.unparse ).to eql "fuup ; \n"
        end
      end

      context 'remove', remove: true do

        it 'item 1 - result is removed node, both unparse sanely' do
          removed_x = result.remove_item_via_string_ 'feep'
          expect( node_s_a ).to eql ['forp']
          expect( result.unparse ).to eql "forp ; \n"
          expect( removed_x ).to eql 'feep'
        end

        it 'item 2 - result is removed node, both unparse sanely' do
          removed_x = result.remove_item_via_string_ 'forp'
          expect( node_s_a ).to eql [ 'feep' ]
          expect( result.unparse ).to eql 'feep ; '
          expect( removed_x ).to eql 'forp'
        end
      end
    end

    using_input_string "fap;fep ; fip ;\n ", 'against three items' do

      context 'add to' do

        it 'position 1 - uses item 1 as prototype' do
          result.insert_item_before_item_string_ 'faap', 'fap'
          expect( @result.unparse ).to eql "faap;fap;fep ; fip ;\n "
        end

        it 'position 2 - uses item 1 as prototype' do
          result.insert_item_before_item_string_ 'faap', 'fep'
          expect( @result.unparse ).to eql "fap;faap;fep ; fip ;\n "
        end

        it 'position 3 - use item 2 as prototype' do
          result.insert_item_before_item_string_ 'faap', 'fip'
          expect( @result.unparse ).to eql "fap;fep ; faap ; fip ;\n "
        end

        it 'position 4 (append) - mutate the final two appropriately' do
          result.append_item_via_string_ 'faap  ;  '
          expect( @result.unparse ).to eql "fap;fep ; fip ; faap ;\n "
        end
      end

      context 'remove', remove: true do

        it 'item 1 - result is removed node, both unparse sanely' do
          removed_x = result.remove_item_via_string_ 'fap'
          expect( node_s_a ).to eql ['fep', 'fip']
          expect( result.unparse ).to eql "fep ; fip ;\n "
          expect( removed_x ).to eql 'fap'
        end

        it 'item 2 - result is removed node, both unparse sanely' do
          removed_x = result.remove_item_via_string_ 'fep'
          expect( node_s_a ).to eql [ 'fap', 'fip' ]
          expect( result.unparse ).to eql "fap;fip ;\n "
          expect( removed_x ).to eql 'fep'
        end
      end
    end
  end
end
