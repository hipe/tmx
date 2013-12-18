require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Box

  ::Skylab::Headless::TestSupport::CLI[ TS__ = self ]

  include CONSTANTS

  Headless = Headless ; MetaHell = MetaHell

  extend TestSupport::Quickie

  QUEUE_IVAR__ = CONSTANTS::QUEUE_IVAR = :@q_x_a


  module ModuleMethods

    def box_class & cls_p
      me = self
      before :all do
        cls = cls_p[]
        me.send :define_method, :box_class do cls end
      end
    end
  end

  module InstanceMethods

    def invoke * s_a
      _a = CONSTANTS::Normalize_argv[ s_a ]
      _ag = box_action
      @result = _ag.invoke _a
      nil
    end

    def box_action
      @box_action ||= build_box_action
    end

    def build_box_action
      _mock_client = mock_client
      _cls = box_class
      _cls.new _mock_client
    end

    def serr_a_bake_notify
      @mock_client.release
    end
  end
end
