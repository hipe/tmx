module Skylab::Headless::TestSupport

  class Client_Spy  # go this away? [#144]

    # use for call_digraph_listeners-spy-style testing of application code (e.g controllers)
    # in a *generic* (modality agnostic) way

    include CONSTANTS
    include Headless_::Client::InstanceMethods

    USE_THIS_PEN = nil

    def initialize
      @debug = NILADIC_TRUTH_  # loud until proven quiet
      @use_this_pen = nil
    end
    NILADIC_TRUTH_ = -> { true }

    attr_reader :debug

    def do_debug_proc= callable
      fail ::ArgumentError.new( 'callable?' ) if ! callable.respond_to?( :call )
      @debug = callable
    end

    def emit_help_line_p
      @ehlp ||= method :emit_help_line
    end

    def emit_help_line s
      call_digraph_listeners :help, s
    end

    def emit_info_line_p
      @eilp ||= method :emit_info_line
    end

    def emit_info_line s
      call_digraph_listeners :info, s  # #todo:during-merge
    end

    def emission_a
      io_adapter.emission_a
    end

  private

    def io_adapter
      @IO_adapter ||= begin
        pen = resolve_pen
        o = Headless_::TestSupport::IO_Adapter_Spy.new( * [ pen ].compact )
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

    USE_THIS_PEN = -> {Headless_::CLI::Pen::MINIMAL }


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
