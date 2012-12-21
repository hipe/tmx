module Skylab::Headless::TestSupport
  class Client_Spy
    # use for emit-spy-style testing of application code (e.g controllers)
    # in a *generic* (modality agnostic) way

    include CONSTANTS
    include Headless::Client::InstanceMethods


    attr_writer :debug

  protected

    def initialize
      @debug = -> { true }        # loud until proved quiet
    end

    def io_adapter
      @io_adapter ||= begin
        o = Headless::TestSupport::IO_Adapter_Spy.new
        o.debug = -> { @debug.call }
        o
      end
    end
  end
end
