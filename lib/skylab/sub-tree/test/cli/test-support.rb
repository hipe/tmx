require_relative '../test-support'
require 'skylab/callback/test/test-support'

module Skylab::SubTree::TestSupport::CLI

  ::Skylab::SubTree::TestSupport[ self ]  # #regret

  module Constants
    PN_ = 'sub-tree'.freeze
  end

  TestLib_ = Constants::TestLib_

  module InstanceMethods

    include Constants # access SubTree_ from within i.m's in the specs

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

    -> do
      stderr = TestSupport_.debug_IO

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
          es.call_digraph_listeners e.stream_name, e.text
        end
      end
      client.instance_variable_set :@program_name, PN_
      client
    end

    attr_reader :names

    def build_client_for_both  # adapted from [fa] (the lib)
      # sadly this has to wire the thing both ways to catch op parse error e's
      @io_mode = :both ; @names = [ ]
      t = @triad_spy = TestSupport_::IO.spy.triad nil  # no fake stin
      do_debug and t.debug!
      es = emit_spy
      client_class.new sin: t.instream, out: t.outstream, err: t.errstream,
        program_name: PN_, wire_p:( -> emtr do
          emtr.on_all do |e|
            es.call_digraph_listeners e.stream_name, e.text
          end
        end )
    end

    def client_class
      SubTree_::CLI::Client
    end

    def emit_spy
      @emit_spy ||= bld_emit_spy
    end

    def bld_emit_spy
      Callback_.test_support.call_digraph_listeners_spy(
        :do_debug_proc, -> { do_debug } )
    end

    def line
      line_thru TestLib_::CLI_lib[].pen.unstyle
    end

    def styled
      line_thru TestLib_::CLI_lib[].pen.unstyle_styled
    end

    def nonstyled
      line_thru Assert_nonstyled_
    end

    Assert_nonstyled_ = -> s do
      x = TestLib_::CLI_lib[].parse_styles s
      x and fail "line was styled, should not have been - #{ x }"
      s
    end

    def line_thru p
      e = emission_a.shift
      if e
        @names.push e.stream_name
        ev = e.payload_x
        _s = if ev.respond_to? :ascii_only? then ev else
          _exag = SubTree_::CLI.some_expression_agent
          _exag.calculate( * ev.a, & ev.p )
        end
        p[ _s ]
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
    EMPTY_S_ = ''.freeze

    def header str
      styled.should eql( str )
      nil
    end

    def one_or_more_styled rx
      styled.should match( rx )
      while @emission_a.length.nonzero?
        e = @emission_a.fetch 0
        s = TestLib_::CLI_lib[].pen.unstyle_styled e.payload_x
        if s  # if it's styled
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
        when :three_streams
          digest_triad_into_emission_a
        when :event
          @emit_spy.emission_a
        when :both
          digest_both_into_emission_a
        else ; fail "io_mode? - #{ @io_mode }"
        end
      end
    end

    def digest_both_into_emission_a
      a = @emit_spy.emission_a
      digest_triad_into a
      a
    end

    def digest_triad_into_emission_a
      digest_triad_into(( y = [ ] ))
      y
    end

    def digest_triad_into y
      t = @triad_spy ; @triad_spy = :digested
      o = t.outstream ; e = t.errstream ; t[ :outstream ] = t[ :errstream ] = nil
      [ [ :out, o ], [ :err, e ] ].each do |(i, io)|
        y.concat io.string.split( "\n" ).map { |s| Emission_[ i, s ] }
      end
      nil
    end

    Emission_ = ::Struct.new :stream_name, :payload_x

    def cd path, &block
      SubTree_::Lib_::Clear_pwd_cache[]
      SubTree_::Library_::FileUtils.cd path, verbose: do_debug, &block
    end
  end
end
