require_relative '../core'
require 'skylab/test-support/core'

module Skylab::GitViz::TestSupport

  module CONSTANTS
    MetaHell = ::Skylab::MetaHell
    GitViz = ::Skylab::GitViz
    Headless = ::Skylab::Headless
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  GitViz = GitViz ; Headless = Headless
  MetaHell = MetaHell ; TS__ = self

  TestSupport::Regret[ self ]

  module ModuleMethods
    def use i
      _mod = MetaHell::Boxxy::Fuzzy_const_get[ TS__, i ]
      _mod[ self ] ; nil
    end
  end

  module InstanceMethods

    def debug!
      @do_debug = true ; nil
    end
    attr_reader :do_debug
    def debug_IO
      GitViz::Headless::System::IO.some_stderr_IO
    end

    def listener
      @listener ||= build_listener
    end

    def build_listener
      GitViz::Services::PubSub[]::Listener::Spy_Proxy.new do |spy|
        spy.emission_a = @baked_em_a = []
        spy.inspect_emission_proc =
          method :inspect_emission_channel_and_payload
        spy.do_debug_proc = -> { do_debug }
        spy.debug_IO = debug_IO
      end
    end

    def inspect_emission_channel_and_payload i_a, x
      "#{ i_a.inspect }: #{ TS__::Expect::Inspect[ x ] }"
    end

    def baked_em_a  # #hook-out: 'expect'
      @baked_em_a ||= build_baked_em_a
    end
  end
end
