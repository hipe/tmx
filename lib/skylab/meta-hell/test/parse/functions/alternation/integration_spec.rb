require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse::Alternation

  describe "[mh] parse functions - alternation - (integration)" do

    before :all do

      Bazzle = Subject_[].new_with(
        :functions,
          :keyword, '--help',
            :moniker_symbol, :do_help,
          :keyword, '-h',
            :moniker_symbol, :do_help,
          :keyword, :server ).to_output_node_and_mutate_array_proc

    end

    it "strange token - nil argv is left alone" do
      argv = %w( strange )
      against( argv ).should be_nil
      argv.length.should eql 1
    end

    it "strange token blocks parsing of subsequent recognized tokens" do
      argv = [ 'strange', '-h' ]
      against( argv ).should be_nil
      argv.length.should eql 2
    end

    it "one recognized token then one strange - parses and consumes" do
      argv = [ '-h', 'strange' ]
      against( argv ).value_x.should eql :do_help
      argv.should eql [ 'strange' ]
    end

    it "two recognizables - only parses first b.c is a branch" do
      argv = [ 'server', '-h' ]
      against( argv ).value_x.should eql :server
      argv.should eql [ '-h' ]
    end

    def against argv
      Bazzle[ argv ]
    end
  end
end
