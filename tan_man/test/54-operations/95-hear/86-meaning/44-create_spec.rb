require_relative '../../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - hear - meaning - create", wip: true do

    TS_[ self ]
    use :operations

# (1/N)
    it "`foo means bar` assigns a heretofor unknown meaning (OMG OMG OMG)" do

      o = given_dotfile_ <<-O.unindent
        digraph {
          # biff : baz
        }
      O

      call_API(
        :hear,
        :word, [ 'foo', 'means', 'bar' ],
        :workspace_path, o.workspace_path,
        :config_filename, o.config_filename,
      )

      expect_OK_event :wrote_resource
      expect_succeed

      _exp = <<-O.unindent
        digraph {
          # biff : baz
          #  foo : bar
        }
      O

      ::File.read( dotfile_path ).should eql _exp
    end

# (2/N)
    it "assign a known meaning to a new value" do

      o = given_dotfile_ <<-O.unindent
        digraph {
          # success : red
        }
      O

      call_API(
        :hear,
        :word, [ 'success', 'means', 'blue' ],
        :workspace_path, o.workspace_path,
        :config_filename, o.config_filename,
      )

      expect_OK_event :wrote_resource
      expect_succeed

      _exp = <<-O.unindent
        digraph {
          # success : blue
        }
      O

      ::File.read( dotfile_path ).should eql _exp
    end

    ignore_these_events :using_parser_files
  end
end
