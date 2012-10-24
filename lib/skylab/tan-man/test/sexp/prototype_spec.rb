require_relative 'test-support'

describe "#{::Skylab::TanMan::Sexp::Prototype} will be awesome" do
  self::Sexp = ::Skylab::TanMan::Sexp
  extend self::Sexp::TestSupport

  self.grammars_module_f = ->{ Sexp::TestSupport::Prototype::Grammars }


  using_grammar '70-38-simplo' do
    using_input_string '', 'totally empty input string' do
      it 'has no list controller' do
        result.node_list.should be_nil
      end
    end
    using_input_string "\n\t  ", 'whitespace only input string' do
      it 'has no list controller' do
        result.node_list.should be_nil
      end
    end
    using_input_string 'fap;fip', 'two element input string' do
      it 'enumerates' do
        result.node_list.nodes
        result.node_list.nodes.should eql(['fap', 'fip'])
      end
    end
    using_input 'invalid-prototype' do
      it 'raises a runmun error at parse time' do
        ->{ result }.should raise_error(/when parsing .+prototype/)
      end
    end
    using_input 'two-element-prototype' do
      it 'appends a valid string as an item' do
        o = result.node_list
        r = o._append!('faeioup')
        o.object_id.should eql(r.object_id)
        o.unparse.should eql('faeioup ;')
        lines = result.unparse.split("\n")
        lines.length.should eql(2)
        lines.last.should eql(o.unparse)
      end
    end
    def initialize_client o ; o.on_info_f = ->(e) { } end #silence
  end

  using_grammar '70-75-with-prototype' do
    using_input_string 'beginning ending', 'zero' do
      it 'has no list controller' do
        result.node_list.should be_nil
      end
    end
    using_input_string 'beginning feep ending', 'one' do
      it('enumerates') { thing.should eql(['feep']) }
    end
    using_input_string 'beginning fap;fep;fip ending', 'three' do
      it('enumerates') { thing.should eql(['fap', 'fep', 'fip']) }
    end
    using_input 'primordial' do
      it 'has a "list controller" node, which enumerates', wip:true do
        o = result.node_list
        o.should_not be_nil
        o.nodes.should eql([])
        o._append! 'fizlip'
      end
    end

    # --*--
    def initialize_client o ; o.on_info_f = ->(e) { } end #silence
    def thing
      result.node_list.nodes.map(&:unparse)
    end
  end
end
