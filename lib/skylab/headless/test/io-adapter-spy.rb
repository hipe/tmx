module Skylab::Headless::TestSupport

  class IO_Adapter_Spy < TestLib_::Callback_test_support[].call_digraph_listeners_spy

    # Used (at the time of this writing ouside of this product) for doing
    # call_digraph_listeners-spy-style testing of our all-important IO::Adapter, which is like
    # an call_digraph_listeners spy but also needs to provide a Pen.

    attr_reader :pen

  private

    def pen=
      @pen = gets_one_polymorphic_value
      true  # as in KEEP_PARSING_
    end
  end
end
