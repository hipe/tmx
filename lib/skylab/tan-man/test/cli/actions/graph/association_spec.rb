require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI::Actions::Graph

  describe "[tm] CLI ::Actions::Graph association actions:", wip: true do

    extend TanMan_::TestSupport::CLI::Actions::Graph

    it "`graph association add` works and adds a label!!" do

      using_dotfile <<-O.unindent
        digraph {
          one [label="Foo"]
          two [label="Bar"]
        }
      O

      invoke_from_dotfile_dir 'graph', 'association', 'add',
        'fo', 'ba', '--label', 'hoity toity'


      exp = <<-O.unindent
      digraph {
        one [label="Foo"]
        two [label="Bar"]
      one -> two[label="hoity toity"]
      }
      O
      contents = dotfile_pathname.read
      contents.should eql( exp )
    end
  end
end
