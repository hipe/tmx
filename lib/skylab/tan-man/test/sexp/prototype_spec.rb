require_relative 'test-support'

describe "#{::Skylab::TanMan::Sexp::Prototype} will be awesome" do
  self::Sexp = ::Skylab::TanMan::Sexp
  extend self::Sexp::TestSupport

  self.grammars_module_f = ->{ Sexp::TestSupport::Prototype::Grammars }

  using_grammar '70-75-with-prototype' do
    using_input_string 'beginning ending', 'zero', wip:true do
      it('enumerates') { thing.should eql([]) }
    end
    using_input_string 'beginning feep ending', 'one' do
      it('enumerates') { thing.should eql(['feep']) }
    end
    using_input_string 'beginning fap;fep;fip ending', 'three' do
      it('enumerates') { thing.should eql(['fap', 'fep', 'fip']) }
    end
    using_input 'primordial', f:true do
      it "veepie deepie" do
        $stderr.puts("YOIP: #{Sexp}")
        $stderr.puts("WOW: #{result.class}")
      end
    end
    def initialize_client client
      client.on_info_f = ->(e) { } # #silence
    end
    def thing
      result.node_list.nodes.map(&:unparse)
    end
  end
end
