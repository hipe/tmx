require File.expand_path('./support.rb',File.dirname(__FILE__))

module Hipe
  module Assess
    class ControllerGenTestCase < MiniTest::Unit::TestCase
      def setup
        ai = FrameworkCommon::AppInfo.current
        ai.app_root.absolute_path = FrameworkCommon.empty_tmpdir_for!('tests')
      end

      def test_controller_status_1_
        Cmd.ui_push
        Commands.invoke %w(web controller sum)
        resp = Cmd.ui_pop_read
        struct = JSON.parse(resp)
        assert struct.has_key?("controllers"), "controllers summary ok"
      end
    end
  end
end
