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

    attr_reader :emitted

    Fuu = ::Struct.new :stream_name, :string  # #todo during integration only

    def emit *a
      ( @emitted ||= [ ] )  << Fuu.new( * a )
    end

  protected

    def initialize
      @debug = -> { true }        # loud until proved quiet
    end

    def io_adapter
      @io_adapter ||= begin
        pen = resolve_pen
        o = Headless::TestSupport::IO_Adapter_Spy.new( * [ pen ].compact )
        # o.debug = -> { @debug.call } # #todo during integration only
        o
      end
    end

    attr_reader :use_this_pen

    def resolve_pen
      pen = use_this_pen
      if ! pen
        pen = self.class::USE_THIS_PEN
        pen &&= pen.call
      end
      pen
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


    def initialize pen=nil
      @use_this_pen = pen
    end

    def clear!  # #todo during integration
      if emitted
        @emitted.clear
      end
    end
  end
end
