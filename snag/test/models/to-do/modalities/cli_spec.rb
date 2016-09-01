require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - to-do - actions - to stream" do

    extend TS_
    use :expect_my_CLI

    it "regular style - works, is hard to read and boring" do

      invoke( * _action, '-p', _common_pattern, _some_todos )

      __expect_regular_style
    end

    def __expect_regular_style

      expect :o, %r{/ferbis\.code:2:beta %to-dew\z}
      expect :o, %r{jerbis/one\.code:1:line one\b}
      expect :o, %r{jerbis/one\.code:3:line three\b}
      expect :e, /\A\(3 to dos total\)\z/

      expect_succeeded
    end

    it "black and white tree" do

      invoke( * _action, '-t', '-p', _common_pattern, _some_todos )

      __expect_black_and_white_tree
    end

    def __expect_black_and_white_tree

      on_stream :o
      o = flush_to_content_scanner
      ::File.basename( o.next_line.chop! ).should eql 'some-todos'
      o.next_line.should eql "├── ferbis.code\n"
      o.finish.should eql 5

      _expect_common_finish
    end

    it "the `show_command` modifier short-circuits" do

      invoke( * _action, '--show-command', '-p', 'zipperly', _some_todos )

      expect :o, /\Agenerated `find` command: "find -[a-zA-Z]\b/
      expect_result_for_success
    end

    it "colorized tree" do

      invoke( * _action, '-t', '-t', '-p', _common_pattern, _some_todos )

      on_stream :o
      o = flush_to_content_scanner
      o.advance_N_lines 2
      o.next_line[ 0, 15 ].should eql "│  └── \e[1;33m2"
      o.finish.should eql 4

      _expect_common_finish
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

    def _expect_common_finish
      on_stream :e
      expect "(found 3 to do's total)"
      expect_succeeded
    end
  end
end
