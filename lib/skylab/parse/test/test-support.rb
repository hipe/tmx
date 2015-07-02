require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Parse::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  module ModuleMethods

    def memoize_subject_parse_function_ & build_p

      define_method :subject_parse_function_, Callback_::Memoize[ & build_p ]
      NIL_
    end

    def use sym
      Test_Support_Bundles___.const_get(
        Callback_::Name.via_variegated_symbol( sym ).as_const,
        false
      )[ self ]
    end
  end

  module InstanceMethods

    def against_ * s_a
      against_input_array s_a
    end

    def against_input_array s_a
      against_input_stream input_stream_via_array s_a
    end

    def against_input_stream st
      subject_parse_function_.output_node_via_input_stream st
    end

    def the_empty_input_stream
      Home_::Input_Streams_::Array.the_empty_stream
    end

    def input_stream_containing * x_a
      input_stream_via_array x_a
    end

    def input_stream_via_array s_a
      Home_::Input_Streams_::Array.new s_a
    end

    def do_debug
      false
    end
  end

  module Test_Support_Bundles___

    Expect_Event = -> tcm do

      Callback_.test_support::Expect_Event[ tcm ]

      tcm.send(
        :define_method,
        :black_and_white_expression_agent_for_expect_event
      ) do

        Autoloader_.require_sidesystem( :Brazen )::API.expression_agent_instance

      end
    end
  end

  Home_ = ::Skylab::Parse

  Autoloader_ = Home_::Autoloader_
  Callback_ = Home_::Callback_
  EMPTY_A_ = Home_::EMPTY_A_
  IDENTITY_ = -> x { x }
  NIL_ = nil
  UNDERSCORE_ = '_'

  module Constants
    Home_ = Home_
    TestSupport_ = TestSupport_
  end
end
