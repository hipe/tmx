require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Client

  ::Skylab::Headless::TestSupport::CLI[ TS__ = self ]

  include CONSTANTS

  Headless = Headless

  extend TestSupport::Quickie

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

    def invoke * argv
      argv.flatten!
      @result = client.invoke argv ; nil
    end

    def client
      @client ||= build_client
    end

    def build_client
      _a = triad.to_a
      cli = client_class.new( * _a )
      cli.program_name = HERP__
      cli
    end

    HERP__ = 'herp'.freeze

    def bake_serr_a  #hook-out
      t = triad
      @triad = :_spent_
      t.errstream.string.split Headless::LINE_SEPARATOR_STRING_
    end

    def triad
      @triad ||= begin
        t = TestSupport::IO::Spy::Triad.new( * stdin_spy )
        do_debug and t.debug!
        t
      end
    end

    def stdin_spy  # :#hook-in
    end

    def errstring
      triad.errstream.string
    end

    def errstr
      errstring.strip
    end
  end
end
