require_relative '../test-support'
require 'skylab/pub-sub/test/test-support'

module Skylab::SubTree::TestSupport::CLI

  ::Skylab::SubTree::TestSupport[ self ]  # #regret

  module CONSTANTS
    PubSub_TestSupport = ::Skylab::PubSub::TestSupport
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
    #
    attr_reader :result

    attr_accessor :do_debug

    def debug!
      @do_debug = true
    end

    -> do
      stderr = TestSupport::Stderr_[]

      define_method :dputs do |x|
        stderr.puts x
      end
    end.call

    def client  # (avoiding `let` just for ease of step-debugging)
      @client ||= build_client
    end

    def build_client
      build_client_for_events
    end

    def build_client_for_events
      @io_mode = :event ; @names = [ ]
      es = emit_spy
      client = client_class.new do |clnt|
        clnt.on_all do |e|
          es.emit e.stream_name, e.text
        end
      end
      client.instance_variable_set :@program_name, PN_
      client
    end

    attr_reader :names

    def build_client_for_both  # adapted from [fa] (the lib)
      # sadly this has to wire the thing both ways to catch op parse error e's
      @io_mode = :both ; @names = [ ]
      t = @triad_spy = TestSupport::IO::Spy::Triad.new nil  # no fake stin
      do_debug and t.debug!
      es = emit_spy
      client_class.new sin: t.instream, out: t.outstream, err: t.errstream,
        program_name: PN_, wire_p:( -> emtr do
          emtr.on_all do |e|
            es.emit e.stream_name, e.text
          end
        end )
    end

    def client_class
      SubTree::CLI::Client
    end

    def emit_spy
      @emit_spy ||= begin
        es = PubSub_TestSupport::Emit_Spy.new
        es.debug = -> { do_debug }
        es
      end
    end

    def line
      line_thru Unstyle_
    end

    def styled
      line_thru Unstyle_styled_
    end

    def nonstyled
      line_thru Assert_nonstyled_
    end

    Unstyle_, Unstyle_styled_ = ::Skylab::Headless::CLI::Pen::FUN.
      at :unstyle, :unstyle_styled

    Assert_nonstyled_ = -> s do
      (( x = Parse_styles_[ s ] )) and fail "line was styled, should #{
        }not have been - #{ x }"
      s
    end
    #
    Parse_styles_ = ::Skylab::Headless::CLI::FUN.parse_styles

    def line_thru p
      e = emission_a.shift
      if e
        @names.push e.stream_name
        txt = e.payload_x
        ::String === txt or fail "::String? - #{ txt.class }"
        p[ txt ]
      end
    end

    def no_more_lines
      @emission_a.length.zero? or fail "expected no more lined, had - #{
        }#{ @emission_a.fetch( 0 ).inspect }"
    end

    def any_blanks
      while @emission_a.length.nonzero?
        e = @emission_a.fetch 0
        EMPTY_S_ == e.payload_x or break
        @emission_a.shift
      end
      nil
    end
    #
    EMPTY_S_ = ::Skylab::Headless::EMPTY_S_  # track it just for fun

    def header str
      styled.should eql( str )
      nil
    end

    def one_or_more_styled rx
      styled.should match( rx )
      while @emission_a.length.nonzero?
        e = @emission_a.fetch 0
        if (( s = Unstyle_styled_[ e.payload_x ] ))  # if it's styled
          if rx =~ s
            @emission_a.shift
            next
          end
        end
        break
      end
      nil
    end

    def emission_a
      @emission_a ||= begin
        case @io_mode
        when :event
          @emit_spy.emission_a
        when :both
          digest_both_into_emission_a
        else ; fail "io_mode? - #{ @io_mode }"
        end
      end
    end

    def digest_both_into_emission_a
      m = @emit_spy.emission_a
      t = @triad_spy ; @triad_spy = :digested
      o = t.outstream ; e = t.errstream ; t[ :outstream ] = t[ :errstream ] = nil
      [ [ :out, o ], [ :err, e ] ].each do |(i, io)|
        m.concat io.string.split( "\n" ).map { |s| Emission_[ i, s ] }
      end
      m
    end

    Emission_ = ::Struct.new :stream_name, :payload_x

    def cd path, &block
      SubTree::Headless::CLI::PathTools.clear
      SubTree::Services::FileUtils.cd path, verbose: do_debug, &block
    end
  end
end
