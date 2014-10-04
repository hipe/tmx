module Skylab::Headless::TestSupport

  class IO_Adapter_Spy < TestLib_::Callback_test_support[]::Call_Digraph_Listeners_Spy

    # Used (at the time of this writing ouside of this product) for doing
    # call_digraph_listeners-spy-style testing of our all-important IO::Adapter, which is like
    # an call_digraph_listeners spy but also needs to provide a Pen.


    def initialize * x_a
      :pen == x_a.first or raise ::ArgumentError, "iambic hack"
      @pen = x_a.fetch 1
      x_a[ 0, 2 ] = EMPTY_A_
      init_via_iambic x_a
    end

    attr_reader :pen
  end
end
