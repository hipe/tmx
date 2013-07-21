require_relative '../test-support'
require 'skylab/pub-sub/test/test-support'

module Skylab::SubTree::TestSupport::CLI

  ::Skylab::SubTree::TestSupport[ self ]  # #regret

  module CONSTANTS
    SubTree = ::Skylab::SubTree
    PubSub_TestSupport = ::Skylab::PubSub::TestSupport
    TestSupport = ::Skylab::TestSupport
    PN_ = 'sub-tree'.freeze
  end

  module InstanceMethods

    include CONSTANTS # access SubTree from within i.m's in the specs

    # (in pre-order from the first test.)

    def argv *argv
      if do_debug
        dputs "argv : #{ argv.inspect }"
      end
      @result = client.invoke argv
      if do_debug
        dputs "RESULT: #{ @result.inspect }"
      end
      nil
    end

    attr_accessor :do_debug

    def debug!
      @do_debug = true
    end

    -> do
      stderr = $stderr

      define_method :dputs do |x|
        stderr.puts x
      end
    end.call

    def client  # (avoiding `let` just for ease of step-debugging)
      @client ||= begin
        @names ||= [ ]
        es = emit_spy
        client = SubTree::CLI.new do |clnt|
          clnt.on_all do |e|
            es.emit e.stream_name, e.text
          end
        end
        client.instance_variable_set :@program_name, PN_
        client
      end
    end

    PN_ = 'sub-tree'.freeze

    def emit_spy
      @emit_spy ||= begin
        es = PubSub_TestSupport::Emit_Spy.new
        es.debug = -> { do_debug }
        es
      end
    end

    unstylize = unstylize_stylized = nil

    define_method :line do
      e = emission_a.shift
      if e
        names.push e.stream_name
        txt = e.payload_x
        ::String === txt or fail 'blearg'
        unstylize[ txt ] or txt
      end
    end

    def emission_a
      emit_spy.emission_a
    end

    unstylize, unstylize_stylized =
      ::Skylab::Headless::CLI::Pen::FUN.instance_exec do
        [ self.unstylize, self.unstylize_stylized ]
      end

    attr_reader :result

    attr_reader :names

    def cd path, &block
      SubTree::Headless::CLI::PathTools.clear
      SubTree::Services::FileUtils.cd path, verbose: do_debug, &block
    end
  end
end
