require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Starter

  describe "[tm] models starter set" do

    extend TS_

    it "when bad name - shows good names" do

      prepare_ws_tmpdir <<-HERE.unindent
        --- /dev/null
        +++ b/local-conf.d/config
        @@ -0,0 +1 @@
        +using_starter=holy-foly.dot
      HERE

      @ws_tmpdir = CONSTANTS::TMPDIR

      call_API :starter, :set, :name, 'wiz', :workspace_path, @ws_tmpdir.to_path

      expect_not_OK_event :entity_not_found do |ev|
        s_a = ev.a_few_ent_a.map( & :local_entity_identifier_string )
        s_a.should eql [ "digraph.dot", "holy-smack.dot" ]
        ev.ent.local_entity_identifier_string.should eql 'wiz'
      end
      expect_failed
    end

    it "good name, no workspace path" do
      call_API :starter, :set, :name, 'digr'
      expect_not_OK_event :missing_required_properties
      expect_failed
    end

    it "good name, workspace path, but config parse error" do

      prepare_ws_tmpdir <<-HERE.unindent
        --- /dev/null
        +++ b/local-conf.d/config
        @@ -0,0 +1 @@
        +using_starter=hoitus-toitus.dot
      HERE

      call_API :starter, :set, :name, 'digraph.dot',
        :workspace_path, @ws_tmpdir.to_path,
        :config_filename, cfn

      expect_not_OK_event :config_parse_error, "section expected (1:1)"
      expect_failed
    end

    it "good name, workspace path, good config" do

      prepare_ws_tmpdir <<-HERE.unindent
        --- /dev/null
        +++ b/local-conf.d/config
        @@ -0,0 +1,2 @@
        +[ misc ]
        +using-starter = fizzibble.dot
      HERE

      @pn = @ws_tmpdir.join cfn

      call_API :starter, :set, :name, 'digr',
        :workspace_path, @ws_tmpdir.to_path,
        :config_filename, 'local-conf.d/config'

      expect_OK_event :normalized_value
      expect_OK_event :datastore_resource_committed_changes do |ev|
        ev.bytes.should eql 63
      end
      expect_succeeded

      @output_s = @pn.read

      line_a = excerpt( -2 .. -1 ).split( NEWLINE_ )
      line_a[ 0 ].should eql 'using-starter = fizzibble.dot'
      line_a[ 1 ].should eql '[starter "digraph.dot"]'
    end

    def cfn
      CONFIG_FILENAME___
    end
    CONFIG_FILENAME___ = 'local-conf.d/config'.freeze

  end
end
