require_relative '../test-support'

module Skylab::Callback::TestSupport::Actor::Methodic

  Parent_TS_ = ::Skylab::Callback::TestSupport::Actor

  Parent_TS_[ self ]

  include Constants

  extend TestSupport_::Quickie

  Enhance_for_test_ = -> mod do

    mod.module_exec do

      public :iambic_stream_via_iambic_array, :process_iambic_stream_passively

      def process_passively * x_a
        process_iambic_stream_passively iambic_stream_via_iambic_array x_a
      end

      def process_fully * x_a
        process_iambic_stream_fully iambic_stream_via_iambic_array x_a
      end
    end

    nil
  end

  Constants::Enhance_for_test_ = Enhance_for_test_

  Parent_subject_ = Parent_TS_::Subject_

end
