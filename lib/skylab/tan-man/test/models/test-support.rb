require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models

  ::Skylab::TanMan::TestSupport[ self ]

  include CONSTANTS

  TanMan_ = TanMan_ ; TestLib_ = TestLib_

  Brazen_ = TanMan_::Brazen_

  module CONSTANTS

    Within_silo = -> silo_name_i, instance_methods_module do
      _NODE_ID_ = Brazen_.node_identifier.via_symbol silo_name_i
      instance_methods_module.send :define_method, :silo_node_identifier do
        _NODE_ID_
      end  ; nil
    end
  end

  module InstanceMethods

    TestLib_::API_expect[ self ]

    def bld_event_receiver
      evr = super
      evr.add_event_pass_filter do |ev|
        :using != ev.terminal_channel_i
      end
      evr
    end

    def collection_controller
      @collection_controller ||= b_c_c
    end

    def b_c_c
      silo
      _id = @silo.model_class.node_identifier
      evr = event_receiver
      kernel = self.kernel

      @action = Mock_Action__.new evr, kernel

      send :"add_arg_when_#{ input_mechanism_i }"

      _g = Brazen_::Model_::Preconditions_::Graph.new @action, evr, kernel

      @silo.provide_collection_controller_prcn _id, _g, evr
    end

    def add_arg_when_input_file_granule
      _pn = input_file_pathname
      @action.argument_box.add :input_pathname, _pn ; nil
    end

    def silo_controller
      @silo_controller ||= b_s_c
    end

    def silo
      @silo ||= b_s
    end

    def b_s
      kernel.silo_via_identifier silo_node_identifier
    end

    def kernel
      subject_API.application_kernel
    end
  end

  class Mock_Action__

    def initialize * a
      @event_receiver, @kernel = a
      @argument_box = Brazen_::Box_.new
    end

    attr_reader :argument_box

    def controller_nucleus
      [ @event_receiver, @kernel ]
    end
  end
end
