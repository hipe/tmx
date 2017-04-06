require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - node prototypes", wip: true do

    TS_[ self ]
    use :models_node

    using_input 'simple-prototype-and-graph-with/zero.dot' do

# (1/N)
      it 'can add a node to zero nodes' do
        number_of_nodes.should be_zero
        o = touch_node_via_label 'cyan'
        o.unparse.should eql "cyan [label=cyan]"  # :node_stmt
        number_of_nodes.should eql 1

        _i_a = node_sexp_stream.map_by( & :node_id ).to_a
        _i_a == %i( cyan ) || fail

        unparsed[ -24 .. -1 ].should eql "*/\n\ncyan [label=cyan]\n}\n"
      end

      context 'having quotes in labels' do

# (2/N)
        it 'that are unescaped unparses AND stringifies correctly' do
          str = %<it's a quote: ">
          o = touch_node_via_label str
          unparsed.should be_include('[label="it\'s a quote: \""]')
          o.label.should eql str
        end
      end
    end

    using_input 'simple-prototype-and-graph-with/one-that-comes-before.dot' do

# (3/N)
      it 'can add a node to one node' do
        number_of_nodes.should eql 1
        o = touch_node_via_label 'cyan'
        number_of_nodes.should eql 2

        _i_a = node_sexp_stream.map_by( & :node_id ).to_a

        _i_a.should eql [ :blue, :cyan ]
        o.unparse.should eql "cyan [label=cyan]"
        a = unparsed.split NEWLINE_
        a.pop.should eql '}'
        a.pop.should eql 'cyan [label=cyan]'
        a.pop.should eql 'blue [label=blue]'
      end
    end

    using_input 'simple-prototype-and-graph-with/one-that-comes-after.dot' do

# (4/N)
      it 'can add a node to one node' do
        number_of_nodes.should eql 1
        o = touch_node_via_label 'cyan'
        number_of_nodes.should eql 2

        _i_a = node_sexp_stream.map_by( & :node_id ).to_a

        _i_a.should eql [ :cyan, :red ]

        o.unparse.should eql "cyan [label=cyan]"

        a = unparsed.split NEWLINE_
        a.pop.should eql '}'
        a.pop.should eql EMPTY_S_ # we made an extra one on purpose
        a.pop.should eql 'red [label=red]'
        a.pop.should eql 'cyan [label=cyan]'
        a.pop.should eql EMPTY_S_
        a.pop.should eql '*/'
      end
    end

    using_input 'simple-prototype-and-graph-with/three.dot' do

      context 'it adds nodes "alphabetically" but does not rearrange existing' do

# (5/N)
        it 'when first one comes after new one, new one goes first' do
          add 'beta'
          expect :beta, :gamma, :alpha, :yeti
        end

# (6/N)
        it '(inside)' do
          add 'ham'
          expect :gamma, :alpha, :ham, :yeti
        end

# (7/N)
        it '(last)' do
          touch_node_via_label 'zap'
          expect :gamma, :alpha, :yeti, :zap
        end

        def add str
          touch_node_via_label str
        end

        def expect * sym_a
          _i_a = node_sexp_stream.map_by( & :node_id ).to_a
          _i_a == sym_a || fail
        end
      end

# (8/N)
      it 'will not redundantly add a new node if one with same label exists' do
        number_of_nodes.should eql 3
        item = retrieve_any_node_with_id :yeti
        item.nil?.should eql false
        ohai = touch_node_via_label 'yeti'
        ohai.object_id.should eql item.object_id
        number_of_nodes.should eql 3
        expect_OK_event :found_existing_node, 'found existing node (lbl "yeti")'
        expect_no_more_events
      end
    end
  end
end
