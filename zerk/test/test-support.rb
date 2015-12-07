module Skylab::Brazen::TestSupport

  module Zerk

    class << self

      def prepare_test_context tcc
        TestLib_::Expect_event[ tcc ]
        tcc.include self
        NIL_
      end

      def write_constants_into mod
        mod.const_set :Home_, Home_
        mod.const_set :Zerk_, Home_::Zerk
        NIL_
      end
    end  # >>

    def call * x_a
      @branch ||= build_branch
      Zerk_::API.produce_bound_call x_a, @branch
    end

    def build_branch
      branch_class.new build_mock_parent
    end

    def build_mock_parent
      evr = event_receiver_for_expect_event
      Mock_Parent__.new -> i_a, & ev_p do
        evr.maybe_receive_on_channel_event i_a, & ev_p
      end
    end

    Mock_Parent__ = ::Struct.new :handle_event_selectively_via_channel do

      def is_interactive
        false
      end
    end

    write_constants_into self
  end
end
