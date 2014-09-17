module Skylab::Brazen::TestSupport

  class Expect_Event

    class << self

      def [] test_context_cls
        test_context_cls.include Test_Context_Instance_Methods__ ; nil
      end
    end

    module Test_Context_Instance_Methods__

      def expect_one_event * x_a, & p
        expect_event_via_iambic_and_proc x_a, p
        expect_no_more_events
      end

      def expect_event * x_a, & p
        expect_event_via_iambic_and_proc x_a, p
      end

      def expect_event_via_iambic_and_proc x_a, p
        exp = Expectation__.new x_a, p
        exp.call_a.each do | method_i, args |
          send method_i, * args
        end ; nil
      end

      def expect_no_events
        @ev_a.should be_nil
      end

      def expect_no_more_events
        if @ev_a.length.nonzero?
          raise "expected no more events, has #{ @ev_a.first.description }"
        end
      end

      def resolve_ev_by_expect_one_event
        if @ev_a.length.zero?
          raise "expected event, had none."
        else
          @ev = @ev_a.shift ; nil
        end
      end

      def via_ev_expect_terminal_channel_of i
        @ev.terminal_channel_i.should eql i
      end

      def via_ev_expect_via_proc p
        p[ @ev ]
      end
    end

    Expectation__ = self

    class Expectation__

      def initialize x_a, p
        y = @call_a = [ [ :resolve_ev_by_expect_one_event ] ]
        scn = Brazen_::Entity_[].iambic_scanner.new 0, x_a
        if scn.unparsed_exists
          y.push [ :via_ev_expect_terminal_channel_of, [ scn.gets_one ] ]

          if p
            y.push [ :via_ev_expect_via_proc, [ p ] ]
          end

          if scn.unparsed_exists
            raise ::ArgumentError,
              "unreasonable expectation: '#{ scn.current_token }'"
          end
        end
      end

      attr_reader :call_a
    end
  end
end
