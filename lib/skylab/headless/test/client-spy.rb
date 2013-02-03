module Skylab::Headless::TestSupport
  class Client_Spy
    # use for emit-spy-style testing of application code (e.g controllers)
    # in a *generic* (modality agnostic) way

    include CONSTANTS
    include Headless::Client::InstanceMethods

    USE_THIS_PEN = nil

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
        pen = self.class::USE_THIS_PEN
        pen &&= pen.call
        o = Headless::TestSupport::IO_Adapter_Spy.new( * [ pen ].compact )
        o.debug = -> { @debug.call }
        o
      end
    end

    def parameter_label x, idx=nil  # ICK
      idx = "[#{ idx }]" if idx
      stem = if ::Symbol === x then x else
        stem = x.name.normalized_local_name  # errors please
      end
      "#{ stem }#{ idx }"
    end
  end

  class Client_Spy::CLI < Client_Spy
    # ok sure, if you really need it
    attr_accessor :normalized_invocation_string

    USE_THIS_PEN = -> { Headless::CLI::Pen::MINIMAL }
  end
end
