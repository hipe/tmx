require_relative 'test-support'

describe "[tm] Sexp::Auto MANIPULULS", g: true do

  extend ::Skylab::TanMan::TestSupport::Sexp::Auto

  using_grammar '70-75-minimal-recursive-list' do

    # adopts language from XML DOM API: insertBefore, appendChild, removeChild

    using_input_string 'fip ;  ', 'a one element input string' do

      context 'adds' do

        it 'before first' do
          -> do
            result._insert_item_before_item 'fap', 'fip'
          end.should raise_error(
            /cannot insert into a list with less than 2 items/i )
        end

        it 'before nil (append)' do
          -> do
            result._insert_item_before_item 'fap', 'fip'
          end.should raise_error(
            /cannot insert into a list with less than 2 items/i )
        end
      end

      context 'removes' do

        it 'the only (and hence last) element, yielding a stub' do
          removed = result._remove! 'fip'
          node_s_a.should eql ::Skylab::TanMan::EMPTY_A_
          removed.unparse.should eql 'fip ;  '
          result.unparse.should eql ::Skylab::TanMan::EMPTY_S_
        end
      end
    end

    using_input_string "feep ; forp ; \n", 'two items' do

      context 'adds' do

        it 'before first, uses first as prototype, and unparsey' do
          inserted = result._insert_item_before_item 'faap', 'feep'
          node_s_a.should eql [ 'faap', 'feep', 'forp' ]
          result.unparse.should eql "faap ; feep ; forp ; \n"
          inserted.object_id.should eql result.object_id  # yikes
        end

        it 'before second using something as prototype' do
          inserted = result._insert_item_before_item 'faap', 'forp'
          node_s_a.should eql ['feep', 'faap', 'forp' ]
          result.unparse.should eql "feep ; faap ; forp ; \n"
          inserted.content.should eql 'faap'
        end

        it 'before nil (append), using 2nd as prototype, and unparsey' do
          inserted = result._append! 'zap'
          node_s_a.should eql [ 'feep', 'forp', 'zap' ]
          result.unparse.should eql "feep ; forp ; \nzap ; \n"
          inserted.unparse.should eql "zap ; \n"
        end
      end

      context 'removes' do

        it 'first, gives removed node, both unparse ok' do
          removed = result._remove!('feep')
          node_s_a.should eql ['forp']
          result.unparse.should eql "forp ; \n"
          removed.unparse.should eql 'feep ; '
        end

        it 'last, gives removed node, both unparse ok' do
          removed = result._remove!('forp')
          node_s_a.should eql [ 'feep' ]
          result.unparse.should eql 'feep ; '
          removed.unparse.should eql "forp ; \n"
        end
      end
    end

    using_input_string "fap;fep ; fip ;\n ", 'three items' do

      context 'adds' do

        it 'before first using 1st as prototype' do
          result._insert_item_before_item 'fapp', 'fap'
          result.unparse.should eql "fapp;fap;fep ; fip ;\n "
        end

        it 'before second using something as prototype' do
          result._insert_item_before_item 'fapp', 'fep'
          result.unparse.should eql "fap;fapp;fep ; fip ;\n "
        end

        it 'before third using something as prototype' do
          result._insert_item_before_item 'fapp', 'fip'
          result.unparse.should eql "fap;fep ; fapp;fip ;\n "
        end

        it 'before nil (append) using 2nd as prototype (FOR NOW)' do
          result._insert_item_before_item 'fapp', nil
          result.unparse.should eql "fap;fep ; fip ;\n fapp ; "
        end
      end

      context 'removes' do

        it 'first, gives removed node, both unparse ok' do
          removed = result._remove!('fap')
          node_s_a.should eql ['fep', 'fip']
          result.unparse.should eql "fep ; fip ;\n "
          removed.unparse.should eql 'fap;'
        end

        it 'middle, gives removed node, both unparse ok' do
          removed = result._remove!('fep')
          node_s_a.should eql [ 'fap', 'fip' ]
          result.unparse.should eql "fap;fip ;\n "
          removed.unparse.should eql 'fep ; '
        end
      end
    end
  end
end
