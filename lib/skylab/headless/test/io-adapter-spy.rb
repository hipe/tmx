module Skylab::Headless::TestSupport

  class IO_Adapter_Spy < TestLib_::Callback_test_support[]::Call_Digraph_Listeners_Spy

    # Used (at the time of this writing ouside of this product) for doing
    # call_digraph_listeners-spy-style testing of our all-important IO::Adapter, which is like
    # an call_digraph_listeners spy but also needs to provide a Pen.

    attr_accessor :pen

  private

    def initialize pen=Headless_::Pen::MINIMAL
      super(  )
      @pen = pen
    end
  end
end
