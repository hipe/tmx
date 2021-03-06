module Skylab::CodeMetrics

  class ThroughputAdapters_::SynchronousRead
    # -
      # read from STDOUT with timeout. behavior on stderr.

      class << self

        def call y, _, sout, serr, w, & p
          o = new
          o.listener = p
          o.sout = sout
          o.serr = serr
          o.w = w
          o.y = y
          o.execute
        end
        alias_method :[], :call
      end  # >>

      # (this is all proof of concept. would need to be exposed more)

      def initialize

        raise ::ArgumentError if block_given?

        @_TSA_limit = 0.33   # time since activity (seconds)
        @_timeout_seconds = 5.0  # exaggerated amount for fun
      end

      attr_writer(
        :listener,
        :sout,
        :serr,
        :w, :y )

      def execute

        sess = LIB_.system_lib::IO::Select.new
        sess.timeout_seconds = @_timeout_seconds

        # ~ an experimental UI nicety

        did_human_keepalive_behavior = false
        num_souts = 0

        sess.heartbeat @_TSA_limit do

          self._COVER_ME

          did_human_keepalive_behavior = true

          if num_souts.zero?
            @listener.call :info, :moment, :thinking_heartbeat
          else
            @listener.call :info, :data, :working_heartbeat do
              num_souts
            end
            num_souts = 0
          end

          NIL_
        end

        # ~

        y = @y

        sess.on @sout do | s |
          num_souts += 1
          s.chomp!
          y << s
        end

        ok = ACHIEVED_
        sess.on @serr do | s |
          s.chomp!
          ok = UNABLE_
          @listener.call :error, :expression, :unexpected_errput do | y_ |
            y_ << "unexpected errput: #{ s }"
          end
        end

        sess.select  # result is total number of bytes read

        if did_human_keepalive_behavior

          @listener.call :info, :done
        end

        ok && @y
      end
    # -
  end
end
