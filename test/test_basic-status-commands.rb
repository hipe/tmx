require 'minitest/autorun'
require 'ruby-debug'
require File.expand_path('./support.rb',File.dirname(__FILE__))
root = File.expand_path('../lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)
require 'assess'
require 'assess/code-builder'

module Hipe
  module Assess
    class BasicStatusCommandsTestCase < MiniTest::Unit::TestCase
      def setup
        ai = FrameworkCommon::AppInfo.current
        ai.app_root.absolute_path = FrameworkCommon.empty_tmpdir_for!('tests')
      end

      def test_start_1_
        Cmd.ui_push
        Commands.invoke []
        resp = Cmd.ui_pop_read
        assert_match(/Commands available/i, resp)
      end

      def test_db_check_2_
        Cmd.ui_push
        Commands.invoke ['db']
        json = Cmd.ui_pop_read
        struct = JSON.parse(json)
        assert_superset(["db_check"], struct.keys, 'db check')
      end

      def test_web_summary_3_
        Cmd.ui_push
        Commands.invoke ['web','summary']
        json = Cmd.ui_pop_read
        struct = JSON.parse(json)
        tgt = %w(name model app_root version server_executable controller db)
        assert_superset(tgt, struct.keys, "good respond message")
      end
    end
  end
end

