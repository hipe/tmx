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

    def emission_a
      io_adapter.emission_a
    end

  private

    def initialize
      @debug = NILADIC_TRUTH_  # loud until proven quiet
      @use_this_pen = nil
    end

    def io_adapter
      @IO_adapter ||= begin
        pen = resolve_pen
        o = Headless::TestSupport::IO_Adapter_Spy.new( * [ pen ].compact )
        o.do_debug_proc = -> { @debug.call }
        o
      end
    end

    def resolve_pen
      @use_this_pen or ( p = self.class::USE_THIS_PEN and p.call )
    end

    def parameter_label x, idx=nil  # ICK
      idx = "[#{ idx }]" if idx
      stem = if ::Symbol === x then x else
        stem = x.normalized_parameter_name  # errors please
      end
      "#{ stem }#{ idx }"
    end
  end

  class Client_Spy::CLI < Client_Spy
    # ok sure, if you really need it
    attr_accessor :normalized_invocation_string

    USE_THIS_PEN = -> { Headless::CLI::Pen::MINIMAL }


    def initialize pen=nil
      @use_this_pen = pen
    end

    def clear!  # #todo during integration
      if emission_a
        @emission_a.clear
      end
    end
  end
end
