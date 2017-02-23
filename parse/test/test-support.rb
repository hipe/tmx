require 'skylab/parse'
require 'skylab/test_support'

module Skylab::Parse::TestSupport

  class << self
    def [] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  module ModuleMethods___

    def memoize_subject_parse_function_ & build_p

      define_method :subject_parse_function_, Common_::Memoize[ & build_p ]
      NIL_
    end

    def use sym
      Test_Support_Bundles___.const_get(
        Common_::Name.via_variegated_symbol( sym ).as_const,
        false
      )[ self ]
    end
  end

  module InstanceMethods___

    def against_ * s_a
      against_input_array s_a
    end

    def against_input_array s_a
      against_input_stream input_stream_via_array s_a
    end

    def against_input_stream st
      subject_parse_function_.output_node_via_input_stream st
    end

    def handle_event_selectively_
      event_log.handle_event_selectively
    end

    def the_empty_input_stream
      Home_::Input_Streams_::Array.the_empty_stream_
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
      Common_.test_support::Expect_Emission[ tcm ]
    end

    Iambic_Grammar = -> tcc do
      TS_::Iambic_Grammar[ tcc ]
    end

    Memoizer_Methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end
  end

  Home_ = ::Skylab::Parse

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Autoloader_ = Home_::Autoloader_
  Common_ = Home_::Common_
  EMPTY_A_ = Home_::EMPTY_A_
  IDENTITY_ = -> x { x }
  NIL_ = nil
  TS_ = self
  UNDERSCORE_ = '_'

  module Constants
    Home_ = Home_
    TestSupport_ = TestSupport_
  end
end
