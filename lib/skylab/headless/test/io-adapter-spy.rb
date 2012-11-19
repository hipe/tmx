module Skylab::Headless::TestSupport
  class IO_Adapter_Spy < ::Skylab::TestSupport::EmitSpy

    # Used (at the time of this writing ouside of this product) for doing
    # emit-spy-style testing of our all-important IO::Adapter, which is like
    # an emit spy but also needs to provide a Pen.


    attr_accessor :pen

  protected

    def initialize pen=Headless::IO::Pen::MINIMAL
      super()
      @pen = pen
    end
  end
end
