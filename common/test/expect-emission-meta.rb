module Skylab::Common::TestSupport

  module Expect_Event::Meta

    # (NOTE can be found as `use :expect_event_meta`)

    # NOTE as part of its public API this node makes a future-compatible
    # promise never to override the failure methods of our test librarires.
    # (do that elsewhere when necessary).

    def self.[] tcc
      tcc.include self
    end

    # -
      # -- emittance

      define_singleton_method :memoize, TestSupport_::MEMOIZE

      def send_potential_event_ * x_a, & ev_p

        event_log.handle_event_selectively.call( * x_a, & ev_p )
        NIL_
      end

      memoize :NOT_OK_EVENT_ do
        Event_Stub__.new false
      end

      memoize :NEUTRAL_EVENT_ do
        Event_Stub__.new nil
      end

      memoize :OK_EVENT_ do
        Event_Stub__.new true
      end

      class Event_Stub__

        def initialize trilean
          @ok = trilean
        end

        def express_into_under y, expag
          x = @ok
          _ = if x
            'an OK'
          elsif x.nil?
            'a neutral'
          else
            'a failure'
          end
          y << "i am #{ _ } event"
        end

        attr_reader(
          :ok,
        )

        def terminal_channel_symbol
          :y
        end

        def to_event
          self
        end

        self
      end

      # -- meta-expectation

      def expect_lone_failure_ msg

        if [ msg ] != @_fail_log
          if @_fail_log
            _ = @_fail_log.fetch 0
            _really_fail "expected #{ msg.inspect }. had #{ _.inspect }"
          else
            _really_fail "expected failure, had none"
          end
        end
      end

      def expect_nothing_failed_

        if _fail_log
          _ = @_fail_log.fetch 0
          _really_fail "expected no failure, had at least one - #{ _.inspect }"
        end
      end

      attr_reader :_fail_log

      def expect_not_OK_emission_ em

        if false != _trilene( em )
          _really_fail "needed not OK event, `ok` was #{ _say_trilene em }"
        end
      end

      def expect_neutral_emission_ em

        if ! _trilene( em ).nil?
          _really_fail "needed neutral event, `ok` was #{ _say_trilene em }"
        end
      end

      def expect_OK_emission_ em

        if true != _trilene( em )
          _really_fail "needed OK event, `ok` was #{ _say_trilene em }"
        end
      end

      def _say_trilene em
        _trilene( em ).inspect
      end

      def _trilene em
        em.cached_event_value.ok
      end

      def _really_fail msg="(this test really failed)"
        ::Kernel.fail msg
      end

      def subject_
        Home_::TestSupport::Expect_Emission
      end
    # -
  end
end
