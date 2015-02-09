require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Client

  ::Skylab::Headless::TestSupport::CLI[ TS__ = self ]

  include Constants

  Headless_ = Headless_

  extend TestSupport_::Quickie

  module ModuleMethods

    def with_client_class &p
      test_context_class = self
      before :all do
        cls = p.call
        test_context_class.send :define_method, :client_class do cls end ; nil
      end
    end
  end

  module InstanceMethods

    # ~ test phase

    def invoke * x_a
      _a = Constants::Normalize_argv[ x_a ]
      _cli = client
      @result = _cli.invoke _a ; nil
    end

    def client
      @client ||= build_client
    end

    def build_client
      _three = three_streams_triad.to_a
      _cls = client_class
      cli = _cls.new( * _three )
      cli.program_name = HERP__
      cli
    end
    HERP__ = 'herp'.freeze

    def three_streams_triad
      @three_streams_triad ||= build_three_streams_triad
    end

    def build_three_streams_triad
      t = TestSupport_::IO.spy.triad.new( * stdin_spy )
      do_debug and t.debug!
      t
    end

    def stdin_spy  # :#hook-in
    end

    # ~ assertion phase

    def errstr
      errstring.strip
    end

    def errstring
      three_streams_triad.errstream.string
    end

    def serr_a_bake_notify  #hook-out
      t = three_streams_triad
      @three_streams_triad = :_spent_
      t.outstream.string.length.zero? or fail say_output( t )
      t.errstream.string.split Headless_::LINE_SEPARATOR_STRING_
    end

    def say_output t
      _s = Headless_.lib_.basic::String.ellipsify t.outstream.string
      "there was output to stderr? \"#{ _s }\")"
    end
  end
end
