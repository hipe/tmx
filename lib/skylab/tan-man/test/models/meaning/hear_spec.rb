require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Meaning

  describe "[tm] models - meaning - hear" do

    extend TS_

    it "`foo means bar` assigns a heretofor unknown meaning (OMG OMG OMG)" do

      using_dotfile <<-O.unindent
        digraph {
          # biff : baz
        }
      O

      call_API :hear,
        :word, [ 'foo', 'means', 'bar' ],
        :workspace_path, @workspace_path,
        :config_filename, cfn_shallow

      expect_OK_event :wrote_resource
      expect_succeeded

      _exp = <<-O.unindent
        digraph {
          # biff : baz
          #  foo : bar
        }
      O

      ::File.read( dotfile_path ).should eql _exp
    end

    it "assign a known meaning to a new value" do

      using_dotfile <<-O.unindent
        digraph {
          # success : red
        }
      O

      call_API :hear,
        :word, [ 'success', 'means', 'blue' ],
        :workspace_path, @workspace_path,
        :config_filename, cfn_shallow

      expect_OK_event :wrote_resource
      expect_succeeded

      _exp = <<-O.unindent
        digraph {
          # success : blue
        }
      O

      ::File.read( dotfile_path ).should eql _exp
    end
  end
end
