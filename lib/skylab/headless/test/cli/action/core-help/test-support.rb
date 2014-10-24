require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Action::Hlp__

  Parent_TS_ = ::Skylab::Headless::TestSupport::CLI::Action

  Parent_TS_[ TS__ = self ]

  include Constants

  Headless_ = Headless_

  extend TestSupport_::Quickie

  Parent_Subject_ = Parent_TS_::Subject_

  module ModuleMethods
    def client_cls_with_op const_i, & op_p
      test_context_class = self
      before :all do
        cls = TS__.const_set const_i, ::Class.new
        cls.class_exec do
          Parent_Subject_[ self, :core_instance_methods ]
          define_method :build_option_parser, -> do
            op = Headless_::Library_::OptionParser.new
            instance_exec op, & op_p
            op
          end

          def initialize( * )
            @_par_x_a_ = []
            super
          end

          def default_action_i
            :go_nanni
          end

          def go_nanni * arg
            @_argv_ = arg
            :_yerp_
          end
          attr_reader :_argv_

          self
        end
        test_context_class.send :define_method, :action_class do cls end ; nil
      end
    end
  end
end
