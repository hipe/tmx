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

    def expect * x_a
      Model_Expectation__.new( @reception_a.shift, x_a, self ).execute
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
  end

  class Listener_Spy__

    def initialize a, do_debug_p, debug_IO_p
      @do_debug_p = do_debug_p ; @debug_IO_p = debug_IO_p
      @reception_a = a
    end

    def receive_error_event ev
      reception = Reception__.new :error_event, ev
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
      @reception, x_a, @context = a
      @chan_i = x_a.first
      @expected_x = x_a.last
      2 < x_a.length and raise ::ArgumentError, "(#{ x_a.length } for 2)"
      @assertion_method_i_a = [ :chan, :str ]
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
    def str
      ev = @reception.ev
      EXPAG__.calculate y=[], ev, & ev.message_proc
      str = y * Snag_::SPACE_
      if str == @expected_x
        PROCEDE__
      else
        str.should @context.send( :eql, @expected_x )
        STOP_EARLY__
      end
    end
  end

  PROCEDE__ = true ; STOP_EARLY__ = false

  EXPAG__ = class Expression_Agent__
    alias_method :calculate, :instance_exec
    def ick x
      "(ick #{ x })"
    end
    self
  end.new
end
