module Skylab::Headless::TestSupport
  class Client_Spy
    # use for emit-spy-style testing of application code (e.g controllers)
    # in a *generic* (modality agnostic) way

    include CONSTANTS
    include Headless::Client::InstanceMethods


    attr_reader :debug

    def debug= callable
      fail ::ArgumentError.new( 'callable?' ) if ! callable.respond_to?( :call )
      @debug = callable
    end

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

  class Client_Spy::CLI < Client_Spy
    # ok sure, if you really need it
    attr_accessor :normalized_invocation_string
  end
end
