require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] CLI - to-do", wip: true do

    TS_[ self ]
    use :my_CLI

    it "regular style - works, is hard to read and boring" do
      invoke( * _action, '-p', _common_pattern, _some_todos )
      __want_regular_style
    end

    def __want_regular_style

      want :o, %r{/ferbis\.code:2:beta %to-dew\z}
      want :o, %r{jerbis/one\.code:1:line one\b}
      want :o, %r{jerbis/one\.code:3:line three\b}
      want :e, /\A\(3 to dos total\)\z/

      want_succeed
    end

    it "black and white tree" do

      invoke( * _action, '-t', '-p', _common_pattern, _some_todos )

      __want_black_and_white_tree
    end

    def __want_black_and_white_tree

      on_stream :o
      o = flush_to_content_scanner
      expect( ::File.basename( o.next_line.chop! ) ).to eql 'some-todos'
      expect( o.next_line ).to eql "├── ferbis.code\n"
      expect( o.finish ).to eql 5

      _want_common_finish
    end

    it "the `show_command` modifier short-circuits" do

      invoke( * _action, '--show-command', '-p', 'zipperly', _some_todos )

      want :o, /\Agenerated `find` command: "find -[a-zA-Z]\b/
      want_result_for_success
    end

    it "colorized tree" do

      invoke( * _action, '-t', '-t', '-p', _common_pattern, _some_todos )

      on_stream :o
      o = flush_to_content_scanner
      o.advance_N_lines 2
      expect( o.next_line[ 0, 15 ] ).to eql "│  └── \e[1;33m2"
      expect( o.finish ).to eql 4

      _want_common_finish
    end

    it "[tmx] integration (stowaway)", TMX_CLI_integration: true do

      Home_::Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'snag', 'ping'

      cli.want_on_stderr "hello from snag.\n"

      cli.want_succeed_under self
    end

    define_method :_action, -> do
      a = [ 'to-do', 'to-stream' ]
      -> do
        a
      end
    end.call

    define_method :_common_pattern, -> do
      s = '%to-dew\>'
      -> { s }
    end.call

    def _some_todos
      Fixture_tree_[ :some_todos ]
    end

    def _want_common_finish
      on_stream :e
      want "(found 3 to do's total)"
      want_succeed
    end
  end
end
