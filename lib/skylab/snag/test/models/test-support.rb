require_relative '../test-support'

module Skylab::Snag::TestSupport::Models

  ::Skylab::Snag::TestSupport[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Snag_ = Snag_

  module InstanceMethods

    def listener_spy
      @listener_spy ||= bld_listener_spy
    end

    def bld_listener_spy
      @reception_a = a = []
      Listener_Spy__.new a, -> { do_debug }, -> { debug_IO }
    end

    def expect * x_a, & p
      Model_Expectation__.new( @reception_a.shift, x_a, p, self ).execute
    end

    def expect_failed
      expect_no_more_events && expect_failure_result
    end

    def expect_succeeded
      expect_no_more_events && expect_success_result
    end

    def expect_no_more_events
      @reception_a.length.zero? or begin
        _msg = "expected no more events, had #{ @reception_a.length } #{
          }(#{ @reception_a.first.to_inspection_string })"
        fail _msg
        STOP_EARLY__
      end
    end

    def expect_success_result
      @result.should eql true
    end

    def expect_failure_result
      @result.should eql false
    end

    # ~ called by expectation agent

    def render_terminal_event ev
      while ev.respond_to? :ev
        ev = ev.ev
      end
      EXPAG__.calculate y=[], ev, & ev.message_proc
      y * Snag_::SPACE_
    end
  end

  class Listener_Spy__

    def initialize a, do_debug_p, debug_IO_p
      @do_debug_p = do_debug_p ; @debug_IO_p = debug_IO_p
      @reception_a = a
    end

    def receive_error_event ev
      rcv :error_event, ev
    end

    def receive_info_event ev
      rcv :info_event, ev
    end

    def rcv i, ev
      reception = Reception__.new i, ev
      if @do_debug_p[]
        @debug_IO_p[].puts reception.to_inspection_string
      end
      @reception_a.push reception ; nil
    end

    Reception__ = ::Struct.new :chan_i, :ev
    class Reception__
      def to_inspection_string
        [ chan_i, ev.class ].inspect
      end
    end
  end

  class Model_Expectation__
    def initialize * a
      @reception, x_a, p, @context = a
      @chan_i = x_a.shift
      a = [ :chan ]
      if x_a.first.respond_to? :id2name
        @term_chan_i = x_a.shift
        a.push :term
      end
      if x_a.length.nonzero?
        @expected_x = x_a.shift
        a.push :str
      end
      if p
        @p = p
        a.push :ev_p
      end
      x_a.length.nonzero? and raise ::ArgumentError, "? #{ x_a.first }"
      @assertion_method_i_a = a
    end
    def execute
      if @reception
        flush_assertions
      else
        @context.send :fail, "expected one more event, had none."
      end
    end
  private
    def flush_assertions
      d = -1 ; last = @assertion_method_i_a.length - 1
      while d < last
        d += 1
        send @assertion_method_i_a.fetch( d ) or break
      end ; nil
    end
    def chan
      if @reception.chan_i == @chan_i
        PROCEDE__
      else
        @reception.chan_i.should @context.send( :eql, @chan_i )
        STOP_EARLY__
      end
    end
    def term
      tci = @reception.ev.terminal_channel_i
      if tci == @term_chan_i
        PROCEDE__
      else
        tci.should @context.send( :eql, @term_chan_i )
        STOP_EARLY__
      end
    end
    def str
      str = @context.render_terminal_event @reception.ev
      if str == @expected_x
        PROCEDE__
      else
        str.should @context.send( :eql, @expected_x )
        STOP_EARLY__
      end
    end
    def ev_p
      @p[ @reception.ev ]
      PROCEDE__
    end
  end

  PROCEDE__ = true ; STOP_EARLY__ = false

  EXPAG__ = class Expression_Agent__
    alias_method :calculate, :instance_exec
    def ick x
      "(ick #{ x })"
    end
    def pth x
      "(pth #{ x })"
    end
    def val x
      "(val #{ x })"
    end
    self
  end.new
end
