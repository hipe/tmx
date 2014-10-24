require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models

  ::Skylab::TanMan::TestSupport[ self ]

  include Constants

  EMPTY_S_ = EMPTY_S_

  NEWLINE_ = NEWLINE_

  TanMan_ = TanMan_ ; TestLib_ = TestLib_

  Brazen_ = TanMan_::Brazen_

  Callback_ = TanMan_::Callback_

  module Constants

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

      _inp_a = send :"bld_input_args_when_#{ input_mechanism_i }"

      @action = Mock_Action__.new _inp_a, evr, kernel


      _g = Brazen_::Model_::Preconditions_::Graph.new @action, evr, kernel

      @silo.provide_collection_controller_prcn _id, _g, evr
    end

    def bld_input_args_when_input_file_granule
      [ Brazen_.model.actual_property.new( input_file_pathname, :input_pathname ) ]
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

    # ~ tmpdir/workspace support

    def use_empty_ws
      td = verbosify_tmpdir empty_dir_pn
      if Do_prepare_empty_tmpdir__[]
        td.prepare
      end
      @ws_pn = td ; nil
    end

    Do_prepare_empty_tmpdir__ = -> do
      p = -> do
        p = NILADIC_EMPTINESS_
        true
      end
      -> { p[] }
    end.call

    NILADIC_EMPTINESS_ = -> { }

    def empty_dir_pn
      TestLib_::Empty_dir_pn[]
    end

    def prepare_ws_tmpdir s=nil
      td = verbosify_tmpdir volatile_tmpdir
      td.prepare
      if s
        td.patch s
      end
      @ws_pn = td ; nil
    end

    def volatile_tmpdir
      TestLib_::Volatile_tmpdir[]
    end

    def verbosify_tmpdir td
      if do_debug
        if ! td.be_verbose
          td = td.with :be_verbose, true, :debug_IO, debug_IO
        end
      elsif td.be_verbose
        self._IT_WILL_BE_EASY
      end
      td
    end

    def cfn
      CONFIG_FILENAME___
    end
    CONFIG_FILENAME___ = 'local-conf.d/config'.freeze
  end

  class Mock_Action__

    def initialize inp_a, evr, k
      @event_receiver = evr
      @input_arguments = inp_a
      @kernel = k
    end

    attr_reader :input_arguments

    def controller_nucleus
      [ @event_receiver, @kernel ]
    end
  end
end
