require_relative '../../test-support'

module Skylab::Parse::TestSupport

  module Fz_Alt___  # :+#throwaway-module for test constants

  TS_.describe "[pa] functions - alternation (integration)" do

    before :all do

      Bazzle = Home_.function( :alternation ).with(
        :functions,
          :keyword, '--help',
            :moniker_symbol, :do_help,
          :keyword, '-h',
            :moniker_symbol, :do_help,
          :keyword, :server ).to_output_node_and_mutate_array_proc

    end

    it "strange token - nil argv is left alone" do
      argv = %w( strange )
      expect( _against( argv ) ).to be_nil
      expect( argv.length ).to eql 1
    end

    it "strange token blocks parsing of subsequent recognized tokens" do
      argv = [ 'strange', '-h' ]
      expect( _against( argv ) ).to be_nil
      expect( argv.length ).to eql 2
    end

    it "one recognized token then one strange - parses and consumes" do
      argv = [ '-h', 'strange' ]
      expect( _against( argv ).value ).to eql :do_help
      expect( argv ).to eql [ 'strange' ]
    end

    it "two recognizables - only parses first b.c is a branch" do
      argv = [ 'server', '-h' ]
      expect( _against( argv ).value ).to eql :server
      expect( argv ).to eql [ '-h' ]
    end

    def _against argv
      Bazzle[ argv ]
    end
  end
  end
end
