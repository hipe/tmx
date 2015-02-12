require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Starter

  describe "[tm] models starter set" do

    TestSupport_::Expect_line[ self ]

    extend TS_

    it "when bad name - shows good names" do

      prepare_ws_tmpdir <<-HERE.unindent
        --- /dev/null
        +++ b/#{ cfn }
        @@ -0,0 +1,2 @@
        +[ xy ]
        +using-starter=holy-foly.dot
      HERE

      call_API :starter, :set,
        :name, 'wiz',
        :workspace_path, @ws_pn.to_path, :config_filename, cfn

      expect_not_OK_event :entity_not_found do |ev_|
        ev = ev_.to_event
        s_a = ev.a_few_ent_a.map( & :natural_key_string )
        s_a.should eql [ "digraph.dot", "holy-smack.dot", "minimal.dot" ]
        ev.name_string.should eql 'wiz'
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
        +++ b/#{ cfn }
        @@ -0,0 +1 @@
        +using_starter=hoitus-toitus.dot
      HERE

      call_API :starter, :set, :name, 'digraph.dot',
        :workspace_path, volatile_tmpdir.to_path,
        :config_filename, cfn

      ev = expect_not_OK_event :config_parse_error
      a = black_and_white_lines ev.to_event
      a[ 0 ].should eql 'section expected in config:1:1'
      a[ 1 ].should eql "  1: using_starter=hoitus-toitus.dot\n"
      a[ 2 ].should eql "     ^"

      expect_failed
    end

    it "good name, workspace path, good config" do

      prepare_ws_tmpdir <<-HERE.unindent
        --- /dev/null
        +++ b/#{ cfn }
        @@ -0,0 +1,2 @@
        +[ misc ]
        +using-starter = fizzibble.dot
      HERE


      @pn = @ws_pn.join cfn

      call_API :starter, :set, :name, 'digr',
        :workspace_path, @ws_pn.to_path,
        :config_filename, cfn

      expect_OK_event :normalized_value
      expect_OK_event :datastore_resource_committed_changes do |ev|
        ev.to_event.bytes.should eql 63
      end
      expect_succeeded

      @output_s = @pn.read

      line_a = excerpt( -2 .. -1 ).split( NEWLINE_ )
      line_a[ 0 ].should eql 'using-starter = fizzibble.dot'
      line_a[ 1 ].should eql '[starter "digraph.dot"]'

    end
  end
end
