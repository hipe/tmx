require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - starter set", wip: true do

    TS_[ self ]
    use :expect_line
    use :operations

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

      expect_not_OK_event :component_not_found do | ev |

        ev = ev.to_event

        _s_a = ev.a_few_ent_a.map( & :natural_key_string )
        _s_a.should eql %w( digraph.dot holy-smack.dot minimal.dot )

        ev.name_string.should eql 'wiz'
      end

      expect_fail
    end

    it "good name, no workspace path" do
      call_API :starter, :set, :name, 'digr'
      expect_not_OK_event COMMON_MISS_
      expect_fail
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

      _em = expect_not_OK_event :config_parse_error

      a = black_and_white_lines _em.cached_event_value.to_event
      a[ 0 ].should eql 'section expected in config:1:1'
      a[ 1 ].should eql "  1: using_starter=hoitus-toitus.dot\n"
      a[ 2 ].should eql "     ^"

      expect_fail
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

      _ev = expect_committed_changes_

      _ev.to_event.bytes.should eql 64

      expect_succeed

      @output_s = @pn.read

      line_a = excerpt( -2 .. -1 ).split( NEWLINE_ )
      line_a[ 0 ].should eql 'using-starter = fizzibble.dot'
      line_a[ 1 ].should eql '[starter "digraph.dot" ]'

    end
  end
end
